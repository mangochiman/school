class Teacher < ActiveRecord::Base
  set_table_name :teacher
	set_primary_key :teacher_id

  has_many :class_room_teachers
  has_many :teacher_class_room_courses

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

  def self.available_teachers
    teacher_position_id = Position.find_by_name("Teacher").position_id
    teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}"
    )
    return teachers
  end

  def self.teachers_without_class_rooms
    teacher_position_id = Position.find_by_name("Teacher").position_id
    teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}
      LEFT JOIN class_room_teachers crt ON crt.teacher_id = e.employee_id
      WHERE crt.teacher_id IS NULL")
    return teachers
  end

  def self.non_teachers_employees
    teacher_position_id = Position.find_by_name("Teacher").position_id
    non_employees_teachers = Employee.find_by_sql("SELECT e.* FROM employee e LEFT JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}
      WHERE ep.position_id IS NULL
      ")
    return non_employees_teachers
  end

end
