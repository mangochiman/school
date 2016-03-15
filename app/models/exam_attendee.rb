class ExamAttendee < ActiveRecord::Base
  set_table_name :exam_attendee
	set_primary_key :exam_attendee_id

  belongs_to :examination, :foreign_key => :exam_id
  belongs_to :student, :foreign_key => :student_id

  after_create :create_student_notification, :create_parent_notification

  def create_student_notification
    student_notification = StudentNotification.new
    student_notification.student_id = self.student.student_id
    student_notification.record_id = self.examination.exam_id
    student_notification.record_type = 'new_examination'
    student_notification.save
  end

  def create_parent_notification
    unless self.student.student_parent.blank?
      guardian_notification = GuardianNotification.new
      guardian_notification.guardian_id = self.student.student_parent.parent_id
      guardian_notification.record_id = self.examination.exam_id
      guardian_notification.record_type = 'new_examination'
      guardian_notification.save
    end
  end
  
end
