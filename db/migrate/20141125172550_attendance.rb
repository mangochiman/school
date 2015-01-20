class Attendance < ActiveRecord::Migration
  def self.up
    create_table :student_attendance, :primary_key => :attendance_id do |t|
      t.string :date
      t.integer :student_id
      t.string :status
      t.string :remark
      t.timestamps
    end
  end

  def self.down
    drop_table :student_attendance
  end
end
