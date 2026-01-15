require_relative '../models/cart'

module UserFeatures
  def user_menu(user)
    cart = Cart.new
    loop do
      puts "\n1. View Products\n2. Add to Cart\n3. View Cart\n4. Checkout\n5. View Orders\n6. Sign Out"
      case gets.to_i
      when 1
        view_products
      when 2
        print "Product ID: "
        product_id = gets.to_i
        product = Product.find(product_id)
        print "Quantity: "
        qty = gets.to_i
        cart.add_product(product, qty)
      when 3
        cart.view
      when 4
        if cart.empty?
          puts "Cart is empty"
        else
          order = cart.checkout
          puts order
          user.add_order(order)
          puts "Order placed successfully"
        end
      when 5
        user.orders.each(&:details)
      when 6
        break
      else
        puts "Invalid option"
      end
    end
  end

  def view_products
    Product.all.each do |p|
      puts "Product ID:#{p.id} Name:#{p.name} Price:#{p.price} (#{p.quantity} available)"
    end
  end
end