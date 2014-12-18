class ExamType < ActiveRecord::Migration
  def self.up
    create_table :exam_type, :primary_key => :exam_type_id do |t|
      t.string :name
      t.string :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_type
  end
end
