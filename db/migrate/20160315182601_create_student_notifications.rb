class CreateStudentNotifications < ActiveRecord::Migration
  def self.up
    create_table :student_notification, :primary_key => :student_notification_id do |t|
      t.integer :student_id
      t.integer :record_id
      t.string :record_type
      t.boolean :seen, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :student_notification
  end
end
