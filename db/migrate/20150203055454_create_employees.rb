class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employee, :primary_key => :employee_id do |t|
      t.string :email
      t.string :fname
      t.string :lname
      t.string :gender
      t.string :dob
      t.string :phone
      t.string :mobile
      t.string :date_of_join
      t.timestamps
    end
  end

  def self.down
    drop_table :employee
  end
end
