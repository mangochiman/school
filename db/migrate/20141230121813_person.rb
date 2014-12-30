class Person < ActiveRecord::Migration
  def self.up
    create_table :person, :primary_key => :person_id do |t|
      t.integer :voided
      t.timestamps
		end
  end

  def self.down
		drop_table :person
  end
end
