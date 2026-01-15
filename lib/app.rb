require_relative 'marketplace'
require_relative 'services/auth_service'
require_relative 'modules/validator'
require_relative 'modules/user_features'
require_relative 'modules/admin_features'
require_relative 'modules/auth_features'
require 'uri'

class App
  include Validator
  include UserFeatures
  include AdminFeatures
  include AuthFeatures

  def initialize
    @store = Marketplace.new
    @usr = AuthService.new("credential.txt")
    @admin_auth = AuthService.new("admin.txt")

    # Ensure default admin exists
    ensure_default_admin
  end

  def ensure_default_admin
    admin_users = @admin_auth.load_users
    if admin_users.empty?
      @admin_auth.sign_up("admin@example.com", "Admin@123")
      @store.add_user(Admin.new("admin@example.com", "Admin@123"))
    end
  end

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