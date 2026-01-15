require_relative '../models/product'

module AdminFeatures
  def admin_menu
    loop do
      puts "\n1. Add Product\n2. Update Product\n3. Delete Product\n4. View Products\n5. Sign Out"
      case gets.to_i
      when 1
        add_product
      when 2
        update_product
      when 3
        delete_product
      when 4
        view_products
      when 5
        puts "Exiting..."
        break
      else
        puts "Invalid option"
      end
    end
  end

  def add_product
    print "Name: "
    name = gets.chomp
    print "Price: "
    price = gets.to_f
    print "Quantity: "
    qty = gets.to_i
    id = Product.all.size + 1
    Product.add(Product.new(id, name, price, qty))
  end

  def update_product
    print "Product ID: "
    product_id = gets.to_i
    product = Product.find(product_id)
    print "New Price: "
    product.price = gets.to_f
    print "New Quantity: "
    product.quantity = gets.to_i
  end

  def delete_product
    print "Product ID: "
    product_id = gets.to_i
    product = Product.find(product_id)
    Product.all.delete(product)
  end
end