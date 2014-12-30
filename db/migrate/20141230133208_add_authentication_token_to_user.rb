class AddAuthenticationTokenToUser < ActiveRecord::Migration
  def self.up
			add_column :users, :authentication_token, :string
  end

  def self.down
  end
end
