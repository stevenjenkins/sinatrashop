require 'sinatra/base'

module Sinatra  
  module ShoppingCart
    module Helpers
      def price_display(price)
        d = price.to_f.to_s.split('.')
        dec = d[1]
        if d[1].to_i < 1
          dec = "00"
        elsif d[1].to_i < 10
          dec = d[1] + "0"
        elsif d[1].to_i > 99
          dec = (d[1][0..2].to_f/10).round.to_s
        end
        "$" + d[0] + "." + dec
      end
    end
  
    def self.registered(app)
      app.helpers ShoppingCart::Helpers

      app.get '/cart' do
        @cart = Cart.new(request.cookies["cart"])
        erb :cart, :locals => { :params => { :order => {}, :credit_card => {} }}
      end

      app.post '/cart/add' do
        response.set_cookie("cart", Cart.add(request.cookies["cart"], params))
        redirect "/cart"
      end

      app.post '/cart/update' do
        response.set_cookie("cart", Cart.update(request.cookies["cart"], params))
        redirect "/cart"
      end

      app.get '/cart/remove/:product_id' do |product_id|
        response.set_cookie("cart", Cart.remove(request.cookies["cart"], product_id))
        redirect "/cart"
      end
      
      app.get '/cart/clear' do
        response.set_cookie("cart", Cart.clear)
        redirect "/cart"
      end
      
      app.post '/cart' do
        @products = Product.all
        begin
          ActiveRecord::Base.transaction do
            order = Order.new(params[:order])
            if order.save
              cart = Cart.new(request.cookies["cart"])
              cart.items.each do |item|
                Orderline.create({ :order_id => order.id,
                  :product_id => item[:product].id,
                  :price => item[:product].price,
                  :quantity => item[:quantity] })
              end
              order.update_attribute(:total, cart.total)
              params[:credit_card][:first_name] = params[:order][:bill_firstname]
              params[:credit_card][:last_name] = params[:order][:bill_lastname]
              credit_card = ActiveMerchant::Billing::CreditCard.new(params[:credit_card])
              if credit_card.valid?
                gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(settings.authorize_credentials)
 
                # Authorize for $10 dollars (1000 cents) 
                gateway_response = gateway.authorize(order.total*100, credit_card)
                if gateway_response.success?
                  gateway.capture(1000, gateway_response.authorization)
                  response.set_cookie("cart", Cart.clear)
                  @success = true
                else
                  raise Exception, gateway_response.message
                end
              else
                raise Exception, "Your credit card was not valid."
              end
            else
              raise Exception, '<b>Errors:</b> ' + order.errors.full_messages.join(', ')
            end
          end
        rescue Exception => e
          @message = e.message 
        end

        @cart = Cart.new(request.cookies["cart"])
        erb :cart
      end
    end
  end
end