class ExaminationResult < ActiveRecord::Base
  set_table_name :exam_result
	set_primary_key :exam_result_id

  belongs_to :examination, :foreign_key => :exam_id
  belongs_to :student, :foreign_key => :student_id

  after_create :create_student_notification, :create_parent_notification

  def create_student_notification
    student_notification = StudentNotification.new
    student_notification.student_id = self.student.student_id
    student_notification.record_id = self.exam_result_id
    student_notification.record_type = 'new_examination_results'
    student_notification.save
  end

  def create_parent_notification
    unless self.student.student_parent.blank?
      guardian_notification = GuardianNotification.new
      guardian_notification.guardian_id = self.student.student_parent.parent_id
      guardian_notification.record_id = self.exam_result_id
      guardian_notification.record_type = 'new_examination_results'
      guardian_notification.save
    end
  end

end
