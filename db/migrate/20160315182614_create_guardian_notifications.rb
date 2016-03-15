class CreateGuardianNotifications < ActiveRecord::Migration
  def self.up
    create_table :guardian_notification, :primary_key => :guardian_notification_id do |t|
      t.integer :guardian_id
      t.integer :record_id
      t.string :record_type
      t.boolean :seen, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :guardian_notification
  end
end
