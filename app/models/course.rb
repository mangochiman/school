class Course < ActiveRecord::Base
  set_table_name :course
	set_primary_key :course_id

  has_many :class_room_courses

end
