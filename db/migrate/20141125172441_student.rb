class Student < ActiveRecord::Migration
  def self.up
    create_table :student, :primary_key => :student_id do |t|
      t.string :username
      t.string :email
      t.string :password
      t.string :fname
      t.string :lname
      t.string :gender
      t.string :dob
      t.string :phone
      t.string :mobile
      t.string :parent_id
      t.string :date_of_join
      t.string :status
      t.string :last_login_date
      t.string :last_login_ip
      t.timestamps
    end
  end

  def self.down
    drop_table :student
  end
end
