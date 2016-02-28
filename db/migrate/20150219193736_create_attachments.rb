class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachment, :primary_key => :attachment_id do |t|
      t.integer :attachment_type_id
      t.string :filename
      t.string :content_type
      t.binary :data, :limit => 50.megabyte
      t.timestamps
    end
  end

  def self.down
    drop_table :attachment
  end
end
