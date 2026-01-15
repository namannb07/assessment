require('./store/order')
require('./store/cart')

class User
  
  def initialize(email, password)
    @email = email
    @password = password
    @orders = []
  end
  def email
    @email
  end

  def orders
    @orders
  end

  def authenticate(password)
    @password == password
  end

  def add_order(order)
    @orders << order
  end
end

