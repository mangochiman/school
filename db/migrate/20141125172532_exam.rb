class Exam < ActiveRecord::Migration
  def self.up
    create_table :exam, :primary_key => :exam_id do |t|
      t.integer :class_room_id
      t.integer :exam_type_id
      t.integer :course_id
      t.integer :semester_audit_id
      t.string :name
      t.string :start_date
      t.timestamps
    end
  end

  def self.down
    drop_table :exam
  end
end
