class Product
  @@products = []

  def self.all
    @@products
  end

  def self.add(product)
    @@products << product
  end

  def self.find(id)
    @@products.find { |p| p.id == id }
  end

  def self.seed
    @@products << Product.new(1, "Leptop", 1000, 5)
    @@products << Product.new(2, "Phone", 500, 10)
    @@products << Product.new(3, "Headphones", 100, 15)
  end

  def id
    @id 
  end

  def name
    @name
  end

  def price
    @price
  end

  def quantity
    @quantity
  end

  def id=(id)
    @id = id
  end

  def name=(name)
    @name = name
  end

  def price=(price)
    @price = price
  end

  def quantity=(quantity)
    @quantity = quantity
  end

  def initialize(id, name, price, quantity)
    
    if price < 0
      raise "invalid prise"
    end

    if quantity < 0
      raise "Invalid quantiti"
    end
    @id = id
    @name = name
    @price = price
    @quantity = quantity
  end

  def available?
    @quantity > 0
  end
end