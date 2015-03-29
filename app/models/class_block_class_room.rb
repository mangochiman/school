require "composite_primary_keys"

class ClassBlockClassRoom < ActiveRecord::Base
  set_table_name :class_block_class_room
  set_primary_keys :class_block_id, :class_room_id
  
  belongs_to :class_block
  belongs_to :class_room
end
