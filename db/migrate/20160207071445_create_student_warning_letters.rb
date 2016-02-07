class CreateStudentWarningLetters < ActiveRecord::Migration
  def self.up
    create_table :student_warning_letter, :primary_key => :student_warning_letter_id do |t|
      t.integer :student_id
      t.integer :semester_audit_id
      t.string :data, :limit => 16777215 #Medium Text #4294967295 long text
      t.timestamps
    end
  end

  def self.down
    drop_table :student_warning_letters
  end
end
