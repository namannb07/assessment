class Users
  FILE = "credential.txt"

  def initialize
    File.write(FILE,"") unless File.exist?(FILE)
  end

  def load_users 
    users = {}
    File.readlines(FILE).each do |line|
      username, password = line.strip.split("=")
      users[username] = password
    end

    users
  end
  
  def save_users(users)
    File.open(FILE,"w") do |file|
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