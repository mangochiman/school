class CreateStudentCards < ActiveRecord::Migration
  def self.up
    create_table :student_card, :primary_key => :student_card_id do |t|
      t.integer :student_id
      t.binary :data, :limit => 50.megabyte
      t.timestamps
    end
  end

  def self.down
    drop_table :student_card
  end
end
