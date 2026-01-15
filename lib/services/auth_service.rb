class AuthService
  def initialize(file_path)
    @file_path = file_path
    File.write(@file_path,"") unless File.exist?(@file_path)
  end

  def load_users 
    users = {}
    File.readlines(@file_path).each do |line|
      username, password = line.strip.split("=")
      users[username] = password
    end

    users
  end
  
  def save_users(users)
    File.open(@file_path,"w") do |file|
      users.each do |username,password|
        file.puts("#{username}=#{password}")
      end
    end
  end

  def sign_up(username, password)
    users = load_users
    
    if users.key?(username)
      puts "Username already exists"
    else 
      users[username] = password
      save_users(users)
      puts "User registered successfully"
    end
  end

  def login(username, password)
    users = load_users

    if users[username] == password
      puts "User logged in successfully"
      return true
    else 
      puts "User not found"
      false
    end
  end
end