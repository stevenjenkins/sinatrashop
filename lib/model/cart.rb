class Cart
  attr_accessor :items
  attr_accessor :total

  def initialize(cookie)
    self.items = []
    cookie.split(';').each do |item|
      self.items << { :product => Product.find(item.split(':')[0]), :quantity => (item.split(':')[1]).to_i }
    end
    self.total = self.items.sum { |item| item[:quantity]*item[:product].price }
  end

  def self.to_hash(cookie)
    cookie ||= ''
    cart = {}
    cookie.split(';').each do |item|
      cart[item.split(':')[0]] = (item.split(':')[1]).to_i
    end
    cart
  end

  def self.to_string(cart)
    cookie = ""
    cart.each do |k, v|
      cookie += "#{k.to_s}:#{v.to_s};" if v > 0 
    end
    cookie
  end

  def self.add(cookie, params)
    cart = to_hash(cookie)
    cart["#{params[:product_id]}"] ||= 0
    cart["#{params[:product_id]}"] += params[:quantity].to_i
    to_string(cart)
  end

  def self.remove(cookie, product_id)
    cart = to_hash(cookie)
    cart[product_id] = 0
    to_string(cart)
  end

  def self.update(cookie, params)
    cart = to_hash(cookie)
    cart.each do |k, v|
      cart[k] = params[:quantity][k].to_i
    end
    to_string(cart)
  end

  def self.clear
    ""
  end
end
