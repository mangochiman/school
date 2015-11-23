class Student < ActiveRecord::Base
  set_table_name :student
	set_primary_key :student_id

  has_one :class_room_student, :foreign_key => :student_id #Not in use
  has_one :student_archive, :foreign_key => :student_id
  has_many :student_courses, :foreign_key => :student_id
  has_many :student_class_room_courses, :foreign_key => :student_id
  has_many :student_class_room_adjustments, :foreign_key => :student_id
  has_many :student_parents, :foreign_key => :student_id
  has_many :student_departments, :foreign_key => :student_id
  has_many :exam_attendees, :foreign_key => :student_id
  has_many :examination_results, :foreign_key => :student_id
  has_many :student_punishments, :foreign_key => :student_id
  has_many :punishments, :through => :student_punishments
  has_many :payments, :foreign_key => :student_id
  has_many :courses, :through => :student_class_room_courses
  has_many :student_photos

  def current_class
    current_class_room = self.student_class_room_adjustments.last.class_room.name rescue nil
    return current_class_room
  end

  def current_active_class
    scra = self.student_class_room_adjustments.last
    return "Not Assigned" if scra.blank?
    unless scra.blank?
      if (scra.status.match(/ACTIVE/i))
        return scra.class_room.name
      else
        return scra.class_room.name.to_s + ' (Not Active)'
      end
    end
  end
  
  def age
    ((Date.today - (self.dob.to_date rescue nil)).to_i/365) rescue 'Error'
  end

  def name
    self.fname.capitalize.to_s + ' ' + self.lname.capitalize.to_s
  end

  def guardian_details
    unless (self.student_parents.blank?)
      fname = self.student_parents.last.parent.fname
      lname = self.student_parents.last.parent.lname
      phone = self.student_parents.last.parent.phone
      phone = 'No phone' if phone.blank?
      return fname.to_s + ' ' + lname.to_s + ' (' +  phone + ')'
    else
      return 'No Guardian'
    end
  end

  def my_guardian
    guardian_name = ''
    unless (self.student_parents.blank?)
      fname = self.student_parents.last.parent.fname
      lname = self.student_parents.last.parent.lname
      guardian_name =  (fname.to_s + ' ' + lname.to_s)
    end
    return guardian_name
  end
  
  def student_parent
    self.student_parents.last
  end
end
