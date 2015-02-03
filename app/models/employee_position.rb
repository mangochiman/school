require "composite_primary_keys"
class EmployeePosition < ActiveRecord::Base
  set_table_name :employee_position
  set_primary_keys :employee_id, :position_id

  belongs_to :position
  belongs_to :employee
end
