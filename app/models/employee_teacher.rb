require "composite_primary_keys"
class EmployeeTeacher < ActiveRecord::Base
  set_table_name :employee_teacher
  set_primary_keys :employee_id, :teacher_id

  #belongs_to :employee
  #belongs_to :teacher, :class_name => "Employee", :foreign_key => :teacher_id
end
