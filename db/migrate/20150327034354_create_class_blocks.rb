class CreateClassBlocks < ActiveRecord::Migration
  def self.up
    create_table :class_block, :primary_key => :class_block_id do |t|
      t.string :name
      t.string :carrying_capacity
      t.timestamps
    end
  end

  def self.down
    drop_table :class_block
  end
end
