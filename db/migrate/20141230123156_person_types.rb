class PersonTypes < ActiveRecord::Migration
  def self.up
	 create_table :person_types, :primary_key => :person_type_id do |t|
      t.string :name
      t.integer :voided
      t.timestamps
		end
  end

  def self.down
		drop_table :person_types
  end
end
