class StudentCard < ActiveRecord::Base
  set_table_name :student_card
	set_primary_key :student_card_id

  belongs_to :student, :foreign_key => "student_id"
end
