require 'digest/sha1'
require 'digest/sha2'

class User < ActiveRecord::Base

  devise :database_authenticatable, :token_authenticatable,
		:authentication_keys => [:login]

	set_table_name :users
	set_primary_key :user_id

	before_save :set_password, :before_create

	attr :plain_password
	#attr_accessor :current_user
	attr_accessor :password_salt
	attr_accessor :encrypted_password
	#attr_accessor :secret_question
	#attr_accessible :encrypted_password
	# User name attribute for Devise

	# Virtual attribute for authenticating by either username or email
	# This is in addition to a real persisted field like 'username'
	attr_accessor :login
	attr_accessible :login, :username, :password, :secret_question

  	def set_password
		# We expect that the default OpenMRS interface is used to create users
		#self.password = self.encrypted_password
		self.password = encrypt(self.password, self.salt)
	end

  def self.authenticate(username, password)
		user = User.find_for_authentication(:username => username)
		if !user.blank?
			user.valid_password?(password) ? user : nil
		end
	end

	def valid_password?(password)
		return false if encrypted_password.blank?
	  	is_valid = Digest::SHA1.hexdigest("#{password}#{salt}") == encrypted_password	|| encrypt(password, salt) == encrypted_password || Digest::SHA512.hexdigest("#{password}#{salt}") == encrypted_password
	end

	def try_to_login(passed_password)
    self.valid_password?(passed_password) ? self : nil
	end

	def password_salt
		salt
	end

	# overwrite this method so that we call the encryptor class properly
	def encrypt_password
	  unless @password.blank?
		self.password_salt = salt
		self.encrypted_password = encrypt(@password, salt)
	  end
	end

	# Because when the database_authenticatable wrote the following method to regenerate the password, which in turn passed incorrect params to the encrypt_password, these overwrite is needed!
	def self.password
		# We expect that the default OpenMRS interface is used to create users
		#self.password = encrypt(self.plain_password, self.salt) if self.plain_password
		#raise @password.to_yaml
		self[:password]
	end

	def password_digest(pwd)
		encrypt(pwd, salt)
	end

	def encrypted_password
		self.password
	end

	# Encrypts plain data with the salt.
	# Digest::SHA1.hexdigest("#{plain}#{salt}") would be equivalent to
	# MySQL SHA1 method, however OpenMRS uses a custom hex encoding which drops
	# Leading zeroes
	def encrypt(plain, salt)
		encoding = ""
		digest = Digest::SHA1.digest("#{plain}#{salt}")
		(0..digest.size-1).each{|i| encoding << digest[i].to_s(16) }
		encoding
	end

	def before_create
		super
		self.salt = User.random_string(10) if !self.salt?
		self.password = User.encrypt(self.password, self.salt)
	end

	def self.random_string(len)
		#generat a random password consisting of strings and digits
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end

	def self.encrypt(password,salt)
		Digest::SHA1.hexdigest(password+salt)
	end

end
