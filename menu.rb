require('./admin')
require('./cart')
require('./order')
require('./product')
require('./store')
require('./user')
require('./check')
require('uri')

class Menu
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&+=]).{8,}\z/
  
  def initialize
    @store = Store.new
  end

  def mainmenu
    loop do
      puts "\n1. Sign Up\n2. Sign In\n3. Create Admin\n4. Admin Login\n5. Exit"
      case gets.to_i
      when 1 
        signup
      when 2 
        signin
      when 3
        create_admin
      when 4
        admin_login
      when 5 
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



    @usr = Users.new

    if email =~ URI::MailTo::EMAIL_REGEXP && password.match?(PASSWORD_REGEX)
      @store.add_user(User.new(email, password))
      @usr.sign_up(email,password)
    elsif !password.match?(PASSWORD_REGEX)
      puts "Please enter a valid password"
    else 
    puts "Please enter a valid email address"
    end
  end

  def signin
    print "Email: "
    email = gets.chop
    print "Password: "
    password = gets.chop

    user = @store.find_user(email)

    @usr = Users.new

    valid = password.match?(PASSWORD_REGEX) && email =~ URI::MailTo::EMAIL_REGEXP

    if @usr.login(email,password) && valid
      if @usr.login(email,password)
        user_menu(user)
      end
    else
      puts "Invalid credentials"
    end
  end

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
      when 6
        break
      else 
        puts "Invalid option"
      end
    end
  end

  def create_admin
    print "Please enter your email: "
    email = gets.chop
    print "Please enter your password: "
    password = gets.chop

    exist = @store.find_user(email)
    
    if email =~ URI::MailTo::EMAIL_REGEXP && !exist
      @store.add_user(User.new(email, password))
      puts "Admin created successfully\nEmail : #{email}"
    elsif exist
      puts "Admin already exists!"
    else 
      puts "Please enter a valid email address"
    end
  end

  def admin_login
    print "Email: "
    email = gets.chop
    print "Password: "
    password = gets.chop

    user = @store.find_user(email)

    if user&.authenticate(password) && email =~ URI::MailTo::EMAIL_REGEXP
      admin_menu
    else
      puts "Invalid credentials"
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
        puts "Exiting..."
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
    name = gets.chop
    print "Price: "
    price = gets.to_f
    print "Quantity: "
    qty = gets.to_i
    id = @store.products.size + 1
    @store.products << Product.new(id, name, price, qty)
  end

  def update_product
    print "Product ID: "
    product_id = gets.to_i
    product = @store.find_product(product_id)
    print "New Price: "
    product.price = gets.to_f
    print "New Quantity: "
    product.quantity = gets.to_i
  end

  def delete_product
    print "Product ID: "
    product_id = gets.to_i
    product = @store.find_product(product_id)
    @store.products.delete(product)
  end
end

aa = Menu.new
aa.mainmenu