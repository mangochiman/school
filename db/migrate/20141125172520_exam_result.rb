class ExamResult < ActiveRecord::Migration
  def self.up
    create_table :exam_result, :id => false do |t|
      t.integer :exam_id
      t.integer :student_id
      t.integer :course_id
      t.string :marks
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_result
  end
end
