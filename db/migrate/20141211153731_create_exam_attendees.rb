class CreateExamAttendees < ActiveRecord::Migration
  def self.up
    create_table :exam_attendee, :primary_key => :exam_attendee_id do |t|
      t.integer :exam_id
      t.integer :student_id
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_attendee
  end
end
