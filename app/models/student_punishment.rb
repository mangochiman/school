require "composite_primary_keys"
class StudentPunishment < ActiveRecord::Base
  set_table_name :student_punishment
  set_primary_keys :student_id, :punishment_id

  belongs_to :student, :foreign_key => :student_id
  belongs_to :punishment, :foreign_key => :punishment_id

  after_create :create_student_notification, :create_parent_notification

  def create_student_notification
    student_notification = StudentNotification.new
    student_notification.student_id = self.student_id
    student_notification.record_id = self.punishment_id
    student_notification.record_type = 'new_punishment'
    student_notification.save
  end

  def create_parent_notification
    unless self.student.student_parent.blank?
      guardian_notification = GuardianNotification.new
      guardian_notification.guardian_id = self.student.student_parent.parent_id
      guardian_notification.record_id = self.punishment_id
      guardian_notification.record_type = 'new_punishment'
      guardian_notification.save
    end
  end

end
