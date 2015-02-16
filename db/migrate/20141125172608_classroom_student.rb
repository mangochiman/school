class ClassroomStudent < ActiveRecord::Migration
  def self.up
    create_table :class_room_student, :primary_key => :class_room_student_id do |t|
      t.integer :class_room_id
      t.integer :student_id
      t.integer :semester_id
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room_student
  end
end
