require_relative('admin')
require_relative('cart')
require_relative('order')
require_relative('product')
require_relative('store')
require_relative('user')
require('uri')

class Menu
  def initialize
    @store = Store.new
    @admin = Admin.new("namannb45@gmail.com", "naman123")
  end

  def mainmenu
    loop do
      puts "\n1. Sign Up\n2. Sign In\n3. Admin Login\n4. Exit"
      case gets.to_i
      when 1 
        signup
      when 2 
        signin
      when 3 
        admin_login
      when 4 
        break
      else 
        puts "Invalid option"
      end
    end
  end

  def signup
    print "Please enter your email: "
    email = gets.chop
    print "Please enter your password: "
    password = gets.chop

    if email =~ URI::MailTo::EMAIL_REGEXP
      @store.add_user(User.new(email, password))
      puts "Signup successful"
    else 
      puts "Please enter a valid email address"
    end
  end

  def signin
    print "Email: "
    email = gets.chomp
    print "Password: "
    password = gets.chomp

    user = @store.find_user(email)

    if user&.authenticate(password) && email =~ URI::MailTo::EMAIL_REGEXP
      user_menu(user)
    else
      puts "Invalid credentials"
    end
  end

  def user_menu(user)
    cart = Cart.new
    loop do
      puts "\n1. View Products\n2. Add to Cart\n3. View Cart\n4. Checkout\n5. View Orders\n6. Sign Out"
      case gets.to_i
      when 1 then view_products
      when 2
        print "Product ID: "
        product_id = gets.to_i
        product = @store.find_product(product_id)
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
          user.add_order(order)
          puts "Order placed successfully"
        end
      when 5
        user.orders.each(&:details)
      when 6 then break
      else puts "Invalid option"
      end
    end
  end

  def admin_login
    print "Email: "
    email = gets.chomp
    print "Password: "
    password = gets.chomp
    if email == @admin.email && @admin.authenticate(password)
      admin_menu
    else
      puts "Invalid admin credentials"
    end
  end

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
        break
      else 
        puts "Invalid option"
      end
    end
  end

  def view_products
    @store.products.each do |p|
      puts "Product ID:#{p.id} Name:#{p.name} Price:#{p.price} (#{p.quantity} available)"
    end
  end

  def add_product
    print "Name: "
    name = gets.chomp
    print "Price: "
    price = gets.to_f
    print "Quantity: "
    qty = gets.to_i
    id = @store.products.size + 1
    @store.products << Product.new(id, name, price, qty)
  end

  def update_product
    print "Product ID: "
    product = @store.find_product(gets.to_i)
    print "New Price: "
    product.price = gets.to_f
    print "New Quantity: "
    product.quantity = gets.to_i
  end

  def delete_product
    print "Product ID: "
    product = @store.find_product(gets.to_i)
    @store.products.delete(product)
  end
end

aa = Menu.new
aa.mainmenu