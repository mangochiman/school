class StudentCourse < ActiveRecord::Base
  set_table_name :student_course
	set_primary_key :student_course_id

  belongs_to :student
end
