require_relative 'order'
require_relative 'cart'

class User
  @@users = []

  def self.all
    @@users
  end

  def self.add(user)
    @@users << user
  end

  def self.find(email)
    @@users.find { |u| u.email == email }
  end
  
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
