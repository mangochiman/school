class GlobalProperty < ActiveRecord::Migration
  def self.up
    create_table :global_property, :primary_key => :global_property_id do |t|
      t.string :property
      t.string :value
      t.binary :data
      t.timestamps
    end
  end

  def self.down
    drop_table :global_property
  end
end
