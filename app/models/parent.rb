require 'digest/sha1'
require 'digest/sha2'

class Parent < ActiveRecord::Base
  set_table_name :parent
  set_primary_key :parent_id

  has_many :student_parents
  has_many :students, :through => :student_parents
  before_save :set_password

  def try_to_login
    User.authenticate(self.username,self.password)
  end

  def self.authenticate(login, password)
    u = find :first, :conditions => {:username => login}
    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(plain)
    encrypt(plain, salt) == password || Digest::SHA1.hexdigest("#{plain}#{salt}") == password || Digest::SHA512.hexdigest("#{plain}#{salt}") == password
  end

  def encrypt(plain, salt)
    encoding = ""
    digest = Digest::SHA1.digest("#{plain}#{salt}")
    (0..digest.size-1).each{|i| encoding << digest[i].to_s(16) }
    encoding
  end

  def set_password
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password,self.salt)
  end

  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.encrypt(password,salt)
    Digest::SHA1.hexdigest(password+salt)
  end
  
  def name
    self.fname.capitalize.to_s + ' ' + self.lname.capitalize.to_s
  end

  def name_and_gender
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    gender = self.gender.first.to_s rescue 'unknown'
    first_name + ' ' + last_name + ' (' + gender + ')'
  end
end
