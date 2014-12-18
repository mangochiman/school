class StudentParent < ActiveRecord::Base
  set_table_name :student_parent
  set_primary_key :student_parent_id

  belongs_to :student
  belongs_to :parent
end
