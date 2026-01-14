class Users 
  def sign_up(username,password)
    registered_users = File.read("Database/username.txt")    

    present = registered_users.include?(username)

    if(present == true)
      puts "Username already present please try the different one\n"
    else 
      File.open("Database/username.txt","a") do |file|
        file.puts(username)
      end
      File.open("Database/password.txt","a") do |file|
        file.puts(password)
      end
      puts "User registered successfully"
    end
  end
  
  def login(username,password) 
    registered_username = File.read("Database/username.txt")
    registered_userpassword = File.read("Database/password.txt")
    
    present_username = registered_username.include?(username)
    present_password = registered_userpassword.include?(password)
    if(present_username && present_password)
      puts "User logged in successfully"
      return true
    else 
      puts "Please enter a valid credentials"
      return false
    end
  end
end
