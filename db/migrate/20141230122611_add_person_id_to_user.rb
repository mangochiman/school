class AddPersonIdToUser < ActiveRecord::Migration
  def self.up
		add_column :users, :person_id, :integer
		add_column :parent, :person_id, :integer
		add_column :teacher, :person_id, :integer
  end

  def self.down
  end
end
