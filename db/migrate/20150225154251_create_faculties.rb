class CreateFaculties < ActiveRecord::Migration
  def self.up
    create_table :faculty, :primary_key => :faculty_id do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :faculty
  end
end
