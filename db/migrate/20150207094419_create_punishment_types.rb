class CreatePunishmentTypes < ActiveRecord::Migration
  def self.up
    create_table :punishment_type, :primary_key => :punishment_type_id do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :punishment_type
  end
end
