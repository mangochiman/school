require "composite_primary_keys"

class TeacherClassRoomCourse < ActiveRecord::Base
  set_table_name :teacher_class_room_course
  set_primary_keys :teacher_id, :class_room_id, :course_id

  belongs_to :teacher, :class_name => "Employee", :foreign_key => :teacher_id
  belongs_to :class_room
  belongs_to :course
end
