class Order < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :bill_firstname
  validates_presence_of :bill_lastname
  validates_presence_of :bill_address1
  validates_presence_of :bill_city
  validates_presence_of :bill_state
  validates_presence_of :bill_zipcode
  validates_presence_of :ship_firstname
  validates_presence_of :ship_lastname
  validates_presence_of :ship_address1
  validates_presence_of :ship_city
  validates_presence_of :ship_state
  validates_presence_of :ship_zipcode
  validates_presence_of :phone
end
