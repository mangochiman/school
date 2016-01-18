class Punishment < ActiveRecord::Base
  set_table_name :punishment
	set_primary_key :punishment_id

  belongs_to :teacher, :class_name => "Employee", :foreign_key => :teacher_id
  belongs_to :punishment_type, :foreign_key => :punishment_type_id
  has_many :student_punishments, :foreign_key => :punishment_id
  has_many :students, :through => :student_punishments, :foreign_key => :student_id
end
