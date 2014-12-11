class Exam < ActiveRecord::Migration
  def self.up
    create_table :exam, :primary_key => :exam_id do |t|
      t.integer :exam_type
      t.integer :course_id
      t.string :name
      t.string :start_date
      t.timestamps
    end
  end

  def self.down
    drop_table :exam
  end
end
