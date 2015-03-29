class ClassBlock < ActiveRecord::Base
  set_table_name :class_block
	set_primary_key :class_block_id

  has_many :class_block_class_rooms
end
