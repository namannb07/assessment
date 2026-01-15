require('./menu_functionality')

class Menu < MenuFunctionality
  

  def main_menu
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

  
end

aa = Menu.new
aa.main_menu