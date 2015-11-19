class Semester < ActiveRecord::Base
  set_table_name :semesters
	set_primary_key :semester_id

  has_many :semester_audits, :foreign_key => :semester_id
end
