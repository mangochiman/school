class CreatePunishments < ActiveRecord::Migration
  def self.up
    create_table :punishment, :primary_key => :punishment_id do |t|
      t.integer :teacher_id
      t.integer :punishment_type_id
      t.integer :semester_audit_id
      t.date :start_date
      t.date :end_date
      t.string :details
      t.timestamps
    end
  end

  def self.down
    drop_table :punishment
  end
end
