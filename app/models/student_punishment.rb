require "composite_primary_keys"
class StudentPunishment < ActiveRecord::Base
  set_table_name :student_punishment
  set_primary_keys :student_id, :punishment_id

  belongs_to :student
  belongs_to :punishment
end
