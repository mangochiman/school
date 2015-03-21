class Teacher < ActiveRecord::Base
  set_table_name :teacher
	set_primary_key :teacher_id

  has_many :class_room_teachers

  def name
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    first_name + ' ' + last_name
  end
  
  def name_and_gender
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    gender = self.gender.first.to_s rescue 'unknown'
    first_name + ' ' + last_name + ' (' + gender + ')'
  end
end
