class StudentClassRoomAdjustment < ActiveRecord::Base
  set_table_name :student_class_room_adjustment
	set_primary_key :adjustment_id

  belongs_to :student
  belongs_to :teacher
  belongs_to :semester
  belongs_to :class_room, :foreign_key => :new_class_room_id
  
end
