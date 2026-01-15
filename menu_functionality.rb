require('./users/admin')
require('./users/user')
require('./store/cart')
require('./store/order')
require('./store/product')
require('./store/store')
require('./users/authenticate')
require('uri')

class MenuFunctionality
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&+=]).{8,}\z/
  
  def initialize
    @store = Store.new
  end
def validate_email(email)
    return email =~ URI::MailTo::EMAIL_REGEXP || email == nil
  end

  def validate_password(password)
    return password.match?(PASSWORD_REGEX) || password == nil
  end

  def signup
    print "Please enter your email: "
    email = gets.chomp
    print "Please enter your password: "
    password = gets.chomp

    @usr = Users.new
    valid = validate_email(email) && validate_password(password)
    if valid
      @store.add_user(User.new(email, password))
      @usr.sign_up(email,password)
    end
    if !validate_email(email)
      puts "Please enter a valid email"
    end
    if !validate_password(password)
      puts "Please enter a valid password"
    end
  end

  def signin
    print "Email: "
    email = gets.chomp
    print "Password: "
    password = gets.chomp

    user = @store.find_user(email)

    @usr = Users.new

    valid = validate_email(email) && validate_password(password)

    if valid
      if @usr.login(email,password)
        user_menu(user)
      end
    end
    if !validate_email(email)
      puts "Please enter a valid email address"
    end
    if !validate_password(password)
      puts "Please enter a valid password"
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

  def create_admin
    print "Please enter your email: "
    email = gets.chomp
    print "Please enter your password: "
    password = gets.chomp

    exist = @store.find_user(email)

    valid = validate_email(email) && validate_password(password)
    
    if valid
      if !exist
        @store.add_user(User.new(email, password))
        puts "Admin created successfully\nEmail : #{email}"
      end 
    end
    if exist
      puts "Admin already exists!"
    end 
    if !validate_email(email)
      puts "Please enter a valid email address"
    end
    if !validate_password(password)
      puts "Please enter a valid password"
    end
  end

  def admin_login
    print "Email: "
    email = gets.chomp
    print "Password: "
    password = gets.chomp

    user = @store.find_user(email)

    valid = 
    if validate_email(email) && validate_password(password)
      if user&.authenticate(password) 
        admin_menu
      end
    end 
    if !validate_email(email)
      puts "Please enter a valid email"
    end 
    if !validate_password(password)
      puts "Please enter a valid password"
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