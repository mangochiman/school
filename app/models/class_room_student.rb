class ClassRoomStudent < ActiveRecord::Base
  set_table_name :class_room_student
	set_primary_key :class_room_student_id

  has_one :class_room, :foreign_key => :class_room_id
end
