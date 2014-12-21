class ExaminationResult < ActiveRecord::Base
  set_table_name :exam_result
	set_primary_key :exam_result_id

  belongs_to :examination, :foreign_key => :exam_id
  belongs_to :student, :foreign_key => :student_id
end
