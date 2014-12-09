class CreateClassRoomCourses < ActiveRecord::Migration
  def self.up
    create_table :class_room_course, :id => false do |t|
      t.integer :class_room_id
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room_course
  end
end
