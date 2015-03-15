class Parent < ActiveRecord::Base
    set_table_name :parent
    set_primary_key :parent_id

    has_one :student_parent, :foreign_key => :parent_id

  def name
    self.fname.capitalize.to_s + ' ' + self.lname.capitalize.to_s
  end
end
