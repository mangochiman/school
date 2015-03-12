class Department < ActiveRecord::Base
  set_table_name :department
	set_primary_key :department_id

  belongs_to :faculty
  has_many :student_departments
end
