class ExamResult < ActiveRecord::Migration
  def self.up
    create_table :exam_result, :primary_key => :exam_result_id do |t|
      t.integer :exam_id
      t.integer :student_id
      t.string :marks
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_result
  end
end
