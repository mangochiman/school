class Classroom < ActiveRecord::Migration
  def self.up
    create_table :class_room, :primary_key => :class_room_id do |t|
      t.integer :year
      t.string :grade
      t.string :section
      t.string :status
      t.string :remarks
      t.integer :teacher_id
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room
  end
end
