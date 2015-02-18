class Student < ActiveRecord::Base
  set_table_name :student
	set_primary_key :student_id

  has_one :class_room_student, :foreign_key => :student_id
  has_many :student_courses, :foreign_key => :student_id
  has_many :student_class_room_adjustments, :foreign_key => :student_id
  has_one :student_parent, :foreign_key => :student_id
  has_many :exam_attendees, :foreign_key => :student_id
  has_many :student_punishments, :foreign_key => :student_id
  has_many :punishments, :through => :student_punishments
  has_many :payments, :foreign_key => :student_id

  def current_class
    current_class_room = self.student_class_room_adjustments.last.class_room.name rescue nil
    if current_class_room.blank?
      current_class_room = self.class_room_student.class_room.name rescue nil
    end
    return current_class_room
  end
end
