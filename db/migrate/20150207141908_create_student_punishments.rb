class CreateStudentPunishments < ActiveRecord::Migration
  def self.up
    create_table :student_punishment, :id => false do |t|
      t.integer :student_id
      t.integer :punishment_id
      t.string :completed
      t.timestamps
    end
  end

  def self.down
    drop_table :student_punishment
  end
end
