class Punishment < ActiveRecord::Base
  set_table_name :punishment
	set_primary_key :punishment_id

  belongs_to :student
  belongs_to :teacher
end
