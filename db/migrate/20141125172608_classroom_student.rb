class ClassroomStudent < ActiveRecord::Migration
  def self.up
    create_table :class_room_student, :id => :false do |t|
      t.integer :class_room_id
      t.integer :student_id
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room_student
  end
end
