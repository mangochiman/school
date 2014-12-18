class CreateSubClassRooms < ActiveRecord::Migration
  def self.up
    create_table :sub_class_rooms, :primary_key => :sub_class_room_id do |t|
      t.integer :class_room_id
      t.string :name
      t.integer :capacity
      t.timestamps
    end
  end

  def self.down
    drop_table :sub_class_rooms
  end
end
