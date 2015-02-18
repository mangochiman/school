class ClassRoom < ActiveRecord::Base
  set_table_name :class_room
	set_primary_key :class_room_id

  has_many :class_room_courses
  has_many :class_room_teachers
  has_many :class_room_students
  has_many :student_class_room_adjustments, :foreign_key => :new_class_room_id
  
  def current_students
    students = []
    students_class_room_adjustments = self.student_class_room_adjustments.find(:all, :conditions => ["status =?",
        'active'])

    students_class_room_adjustments.each do |student_class_room_adjustment|
      next if student_class_room_adjustment.student.blank?
      students << student_class_room_adjustment.student
    end
    
    return students
  end
  
end
