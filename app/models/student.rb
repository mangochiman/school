class Student < ActiveRecord::Base
  set_table_name :student
	set_primary_key :student_id

  has_one :class_room_student, :foreign_key => :student_id
  has_many :student_courses, :foreign_key => :student_id
  has_many :student_class_room_courses, :foreign_key => :student_id
  has_many :student_class_room_adjustments, :foreign_key => :student_id
  has_one :student_parent, :foreign_key => :student_id
  has_many :exam_attendees, :foreign_key => :student_id
  has_many :student_punishments, :foreign_key => :student_id
  has_many :punishments, :through => :student_punishments
  has_many :payments, :foreign_key => :student_id
  has_many :courses, :through => :student_class_room_courses
  has_many :student_photos

  def current_class
    current_class_room = self.student_class_room_adjustments.last.class_room.name rescue nil
    return current_class_room
  end

  def age
    ((Date.today - (self.dob.to_date rescue nil)).to_i/365) rescue 'Error'
  end
end
