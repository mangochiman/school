class Grade < ActiveRecord::Migration
  def self.up
    create_table :grade, :primary_key => :grade_id do |t|
      t.string :name
      t.string :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :grade
  end
end
