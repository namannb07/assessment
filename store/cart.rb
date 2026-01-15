require('./store/order')
require('./store/product')

class Cart
  def initialize
    @items = Hash.new(0)
  end

  def add_product(product, qty)
    if product.quantity < qty
      puts "Not enough stock"
    else 
      @items[product] +=  qty
    end
  end

  def empty?
    @items.empty?
  end

  def total
    @items.sum { |product, qty| product.price * qty }
  end

  def checkout
    @items.each do |product, qty|
      product.quantity -= qty
    end
    order = Order.new(@items.clone)
    @items.clear
    order
  end

  def view
    if @items.size == 0
      puts "Cart is empty"
    end
    @items.each do |product, qty|
      puts "Product: #{product.name}  Quantity: #{qty}"
    end
  end
end