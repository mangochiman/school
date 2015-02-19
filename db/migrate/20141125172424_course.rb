class Course < ActiveRecord::Migration
  def self.up
    create_table :course, :primary_key => :course_id do |t|
      t.string :name
      t.string :description
      t.integer :grade_id
      t.boolean :optional, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :course
  end
end
