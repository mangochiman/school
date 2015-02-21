class CreateStudentPhotos < ActiveRecord::Migration
  def self.up
    create_table :student_photo, :primary_key => :student_photo_id do |t|
      t.integer :student_id
      t.string :filename
      t.string :content_type
      t.binary :data
      t.timestamps
    end
  end

  def self.down
    drop_table :student_photo
  end
end
