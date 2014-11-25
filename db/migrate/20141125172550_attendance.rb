class Attendance < ActiveRecord::Migration
  def self.up
    create_table :attendance, :id => false do |t|
      t.string :date
      t.integer :student_id
      t.string :status
      t.string :remark
      t.timestamps
    end
  end

  def self.down
    drop_table :attendance
  end
end
