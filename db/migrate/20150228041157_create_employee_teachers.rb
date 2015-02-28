class CreateEmployeeTeachers < ActiveRecord::Migration
  def self.up
    create_table :employee_teacher, :id => false do |t|
      t.integer :employee_id
      t.integer :teacher_id
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_teacher
  end
end
