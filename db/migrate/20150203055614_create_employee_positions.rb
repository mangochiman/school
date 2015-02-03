class CreateEmployeePositions < ActiveRecord::Migration
  def self.up
    create_table :employee_position, :id => false do |t|
      t.integer :employee_id
      t.integer :position_id
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_position
  end
end
