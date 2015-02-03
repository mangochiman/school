class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :position, :primary_key => :position_id do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :position
  end
end
