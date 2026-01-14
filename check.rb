class User
  def initialize(name,age)
    @name = name
    @age = age
  end

  def name
    @name
  end

  def age
    @age
  end
end

class Store 
  def initialize
    @users = []
  end

  def createUser(name,age)
    @name = name
    @age = age
    @users << User.new(@name,@age)
  end

  def printUsers
    @users.each do |user|
      puts "Name : #{user.name} and Age : #{user.age}"
    end
  end
end

aa = Store.new
aa.createUser("Naman",22)
aa.createUser("Ritsh",25)
aa.createUser("Rahul",21)
aa.createUser("Ajay",23)

aa.printUsers