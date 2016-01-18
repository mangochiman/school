class StudentClassRoomAdjustment < ActiveRecord::Base
  set_table_name :student_class_room_adjustment
	set_primary_key :adjustment_id

  belongs_to :student
  belongs_to :teacher, :class_name => "Employee", :foreign_key => :teacher_id
  belongs_to :semester
  belongs_to :class_room, :foreign_key => :new_class_room_id

  before_save :add_dates

  def add_dates
    
    semester_audit_id = Semester.current_active_semester_audit.semester_audit_id rescue ''
    start_date = Semester.current_semester_start_date
    end_date = Semester.current_semester_end_date
    raise "Please set active semester first before proceeding. Operation Aborted".to_yaml if semester_audit_id.blank?
    raise "Please set dates for active semester first before proceeding. Operation Aborted".to_yaml if (start_date.blank? || end_date.blank?)
    self.semester_audit_id = semester_audit_id
    self.start_date = start_date
    self.end_date = end_date
  end
  
end
