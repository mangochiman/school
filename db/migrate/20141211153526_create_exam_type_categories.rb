class CreateExamTypeCategories < ActiveRecord::Migration
  def self.up
    create_table :exam_type_category,  :primary_key => :exam_type_category_id  do |t|
      t.inteter :exam_type_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_type_category
  end
end
