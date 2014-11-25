class Parent < ActiveRecord::Migration
  def self.up
    create_table :parent, :primary_key => :parent_id do |t|
      t.integer :email
      t.string :password
      t.string :fname
      t.string :lname
      t.string :dob
      t.string :phone
      t.string :mobile
      t.string :date_of_join
      t.string :status
      t.string :last_login_date
      t.string :last_login_ip
      t.timestamps
    end
  end

  def self.down
    drop_table :parent
  end
end
