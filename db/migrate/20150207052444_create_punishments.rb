class CreatePunishments < ActiveRecord::Migration
  def self.up
    create_table :punishment, :primary_key => :punishment_id do |t|
      t.integer :student_id
      t.integer :teacher_id
      t.date :start_date
      t.date :end_date
      t.string :reason
      t.string :details
      t.string :completed
      t.timestamps
    end
  end

  def self.down
    drop_table :punishment
  end
end
