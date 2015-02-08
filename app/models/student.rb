class Student < ActiveRecord::Base
  set_table_name :student
	set_primary_key :student_id

  has_one :class_room_student, :foreign_key => :student_id
  has_many :student_courses, :foreign_key => :student_id
  has_one :student_parent, :foreign_key => :student_id
  has_many :exam_attendees, :foreign_key => :student_id
  has_many :student_punishments, :foreign_key => :student_id
  has_many :punishments, :through => :student_punishments
end
