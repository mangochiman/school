class ClassRoomStudent < ActiveRecord::Base
  set_table_name :class_room_student
	set_primary_key :class_room_student_id

  belongs_to :class_room, :foreign_key => :class_room_id
  belongs_to :student, :foreign_key => :student_id
end
