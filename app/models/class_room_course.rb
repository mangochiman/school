require "composite_primary_keys"

class ClassRoomCourse < ActiveRecord::Base
  set_table_name :class_room_course
  set_primary_keys :class_room_id, :course_id

  belongs_to :class_room
  belongs_to :course
end
