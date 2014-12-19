class ExamAttendee < ActiveRecord::Base
  set_table_name :exam_attendee
	set_primary_key :exam_attendee_id

  belongs_to :examination, :foreign_key => :exam_id
  belongs_to :student, :foreign_key => :student_id
end
