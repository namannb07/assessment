require_relative 'product'

class Order
  def initialize(items)
    @items = items
    @timestamp = Time.now
  end

  def details
    puts "Order placed at #{@timestamp}"
    @items.each do |product, qty|
      puts "Product:#{product.name}  Quantity: #{qty}"
    end
  end
end