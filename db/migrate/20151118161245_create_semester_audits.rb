class CreateSemesterAudits < ActiveRecord::Migration
  def self.up
    create_table :semester_audit, :primary_key => :semester_audit_id do |t|
      t.integer :semester_id
      t.date :start_date
      t.date :end_date
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :semester_audit
  end
end
