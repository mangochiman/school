require "composite_primary_keys"
class StudentClassRoomCourse < ActiveRecord::Base
  set_table_name :student_class_room_course
  set_primary_keys :student_id, :class_room_id, :course_id

  belongs_to :student
  belongs_to :class_room
  belongs_to :course
end
