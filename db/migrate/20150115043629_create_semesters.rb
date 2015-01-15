class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters, :primary_key => :semester_id do |t|
      t.string :semester_number
      t.timestamps
    end
  end

  def self.down
    drop_table :semesters
  end
end
