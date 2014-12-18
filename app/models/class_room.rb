class ClassRoom < ActiveRecord::Base
  set_table_name :class_room
	set_primary_key :class_room_id

  has_many :class_room_courses
  has_many :class_room_teachers
  has_many :class_room_students
end
