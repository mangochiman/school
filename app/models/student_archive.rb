class StudentArchive < ActiveRecord::Base
  set_table_name :student_archive
  set_primary_key :student_archive_id

  belongs_to :student, :foreign_key => "student_id"
end
