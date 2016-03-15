require "composite_primary_keys"

class UserRole < ActiveRecord::Base
  set_table_name :user_role
  set_primary_keys :username, :role

  belongs_to :user, :foreign_key => :username, :primary_key => :username
end
