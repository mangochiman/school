class CreateAttachmentTypes < ActiveRecord::Migration
  def self.up
    create_table :attachment_type, :primary_key => :attachment_type_id do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :attachment_type
  end
end
