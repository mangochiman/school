class Classroom < ActiveRecord::Migration
  def self.up
    create_table :class_room, :primary_key => :class_room_id do |t|
      t.string :code
      t.string :section
      t.string :status
      t.string :name
      t.string :remarks
      t.timestamps
    end
  end

  def self.down
    drop_table :class_room
  end
end
