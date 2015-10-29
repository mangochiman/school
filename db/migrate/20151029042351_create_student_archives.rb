class CreateStudentArchives < ActiveRecord::Migration
  def self.up
    create_table :student_archive, :primary_key => :student_archive_id do |t|
      t.integer :student_id
      t.string :reason
      t.date :date_archived
      t.timestamps
    end
  end

  def self.down
    drop_table :student_archive
  end
end
