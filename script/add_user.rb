def add_user
  admin = User.find_by_username('admin')
  if admin.blank?
    User.create({
        :username => 'admin',
        :password => 'admin',
        :first_name => 'User',
        :last_name => 'Account'
      })
    puts "Account Created"
    puts "Username : admin"
    puts "Password : admin"
  else
    puts "Admin account already exists"
  end
end
add_user
