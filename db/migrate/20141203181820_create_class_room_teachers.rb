class CreateClassRoomTeachers < ActiveRecord::Migration
  def self.up
    create_table :class_room_teachers, :id => false do |t|
      t.integer :class_room_id
      t.integer :teacher_id
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room_teachers
  end
end
