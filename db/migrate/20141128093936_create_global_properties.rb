class CreateGlobalProperties < ActiveRecord::Migration
  def self.up
    create_table :global_properties do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :global_properties
  end
end
