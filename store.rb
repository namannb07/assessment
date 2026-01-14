class Store
  def initialize
    @products = []
    @users = []
    seed_products
  end

  def products
    @products
  end

  def users
    @users
  end

  def seed_products
    @products << Product.new(1, "Leptop", 1000, 5)
    @products << Product.new(2, "Phone", 500, 10)
    @products << Product.new(3, "Headphones", 100, 15)
  end

  def add_user(user)
    @users << user
  end

  def find_user(email)
    email = email.split('@').first
    email = email.split('+').first
    @users.find { |u| u.email.split('@').first == email }
  end

  def find_product(id)
    @products.find { |p| p.id == id }
  end
end