class AddPersonTypeToPerson < ActiveRecord::Migration
  def self.up
		add_column :person, :person_type, :integer
  end

  def self.down
  end
end
