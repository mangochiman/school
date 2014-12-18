class Teacher < ActiveRecord::Base
  set_table_name :teacher
	set_primary_key :teacher_id

  has_many :class_room_teachers
end
