class CreateTeacherClassRoomCourses < ActiveRecord::Migration
  def self.up
    create_table :teacher_class_room_course, :id => false do |t|
      t.integer :teacher_id
      t.integer :class_room_id
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :teacher_class_room_course
  end
end
