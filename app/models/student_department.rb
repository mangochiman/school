require "composite_primary_keys"
class StudentDepartment < ActiveRecord::Base
  set_table_name :student_department
  set_primary_keys :student_id, :department_id

  belongs_to :student
  belongs_to :department
  
end
