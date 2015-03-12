class CreateStudentDepartments < ActiveRecord::Migration
  def self.up
    create_table :student_department, :id => false do |t|
      t.integer :student_id
      t.integer :department_id
      t.timestamps
    end
  end

  def self.down
    drop_table :student_department
  end
end
