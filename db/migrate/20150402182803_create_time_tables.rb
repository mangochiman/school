class CreateTimeTables < ActiveRecord::Migration
  def self.up
    create_table :time_table, :id => false do |t|
      t.integer :teacher_id
      t.integer :class_room_id
      t.integer :course_id
      t.string :date
      t.string :time
      t.timestamps
    end
  end

  def self.down
    drop_table :time_table
  end
end
