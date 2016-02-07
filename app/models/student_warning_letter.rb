class StudentWarningLetter < ActiveRecord::Base
  set_table_name :student_warning_letter
	set_primary_key :student_warning_letter_id

  belongs_to :student
end
