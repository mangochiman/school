class CreateStudentClassRoomAdjustments < ActiveRecord::Migration
  def self.up
    create_table :student_class_room_adjustment, :primary_key => :adjustment_id do |t|
      t.integer :student_id
      t.integer :teacher_id
      t.integer :old_class_room_id
      t.integer :new_class_room_id
      t.integer :semester_id
      t.date :date
      t.string :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :student_class_room_adjustment
  end
end
