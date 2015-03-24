class Parent < ActiveRecord::Base
    set_table_name :parent
    set_primary_key :parent_id

    has_many :student_parents

  def name
    self.fname.capitalize.to_s + ' ' + self.lname.capitalize.to_s
  end

  def name_and_gender
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    gender = self.gender.first.to_s rescue 'unknown'
    first_name + ' ' + last_name + ' (' + gender + ')'
  end
end
