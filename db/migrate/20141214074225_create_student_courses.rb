class CreateStudentCourses < ActiveRecord::Migration
  def self.up
    create_table :student_course, :primary_key => :student_course_id do |t|
      t.integer :student_id
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :student_course
  end
end
