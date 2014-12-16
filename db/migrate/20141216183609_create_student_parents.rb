class CreateStudentParents < ActiveRecord::Migration
  def self.up
    create_table :student_parent, :primary_key => :student_parent_id do |t|
      t.integer :student_id
      t.inter   :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :student_parent
  end
end
