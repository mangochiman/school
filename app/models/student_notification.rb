class StudentNotification < ActiveRecord::Base
  set_table_name :student_notification
	set_primary_key :student_notification_id

  belongs_to :student, :foreign_key => :student_id
end
