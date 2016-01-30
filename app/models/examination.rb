class Examination < ActiveRecord::Base
  set_table_name :exam
	set_primary_key :exam_id

  belongs_to :class_room, :foreign_key => :class_room_id
  belongs_to :examination_type, :foreign_key => :exam_type_id
  belongs_to :course, :foreign_key => :course_id
  belongs_to :examination_type, :foreign_key => :exam_type_id
  has_many :exam_attendees, :foreign_key => :exam_id
  has_many :students, :through => :exam_attendees, :foreign_key => :exam_id
  has_many :examination_results, :foreign_key => :exam_id

  before_save :add_defaults_data

  def add_defaults_data
    self.semester_audit_id = Semester.current_active_semester_audit.semester_id rescue ''
  end

  def self.result(exam_id, student_id)
    exam_result = ExaminationResult.find(:last, :conditions => ["exam_id =? AND student_id =?", exam_id, student_id])
    return "" if exam_result.blank?
    return exam_result.marks
  end
  
end
