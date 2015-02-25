class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :department, :primary_key => :department_id do |t|
      t.integer :faculty_id
      t.string :name
      t.string :code
      t.timestamps
    end
  end

  def self.down
    drop_table :department
  end
end
