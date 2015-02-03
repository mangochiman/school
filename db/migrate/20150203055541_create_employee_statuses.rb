class CreateEmployeeStatuses < ActiveRecord::Migration
  def self.up
    create_table :employee_status, :primary_key => :employee_status_id do |t|
      t.integer :employee_id
      t.string :status
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_status
  end
end
