class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notification, :primary_key => :notification_id do |t|
      t.integer :record_id
      t.string :record_type
      t.boolean :seen, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :notification
  end
end
