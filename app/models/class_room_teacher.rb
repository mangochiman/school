require "composite_primary_keys"

class ClassRoomTeacher < ActiveRecord::Base
  set_table_name :class_room_teachers
  set_primary_keys :class_room_id, :teacher_id

  belongs_to :class_room
  belongs_to :teacher, :class_name => "Employee", :foreign_key => :teacher_id
end
