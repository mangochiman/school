class CreateClassBlockClassRooms < ActiveRecord::Migration
  def self.up
    create_table :class_block_class_room, :id => false do |t|
      t.integer :class_block_id
      t.integer :class_room_id
      t.timestamps
    end
  end

  def self.down
    drop_table :class_block_class_room
  end
end
