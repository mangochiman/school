class Employee < ActiveRecord::Base
  set_table_name :employee
	set_primary_key :employee_id

  has_one :employee_position
end
