class Faculty < ActiveRecord::Base
  set_table_name :faculty
	set_primary_key :faculty_id

  has_many :departments
end
