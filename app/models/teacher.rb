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

  def self.class_room_teachers(class_room_id)
    teacher_position_id = Position.find_by_name("Teacher").position_id
    class_room_teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}
      INNER JOIN class_room_teachers crt ON crt.teacher_id = e.employee_id
      AND crt.class_room_id=#{class_room_id}")
    return class_room_teachers
  end

  def self.class_room_teachers_by_gender(class_room_id, gender_conditions)
    teacher_position_id = Position.find_by_name("Teacher").position_id
    class_room_teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}
      INNER JOIN class_room_teachers crt ON crt.teacher_id = e.employee_id
      AND crt.class_room_id IN (#{class_room_id}) AND #{gender_conditions}")
    return class_room_teachers
  end

  def self.teachers_by_gender(gender)
    teacher_position_id = Position.find_by_name("Teacher").position_id
    class_room_teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id} AND e.gender = '#{gender}'")
    return class_room_teachers
  end

  def self.class_room_teachers_by_gender_and_course_ids(class_room_ids, gender_conditions, course_ids)
    teacher_position_id = Position.find_by_name("Teacher").position_id
    class_room_teachers = Employee.find_by_sql("SELECT e.* FROM employee e INNER JOIN employee_position ep
      ON e.employee_id = ep.employee_id AND ep.position_id = #{teacher_position_id}
      INNER JOIN class_room_teachers crt ON crt.teacher_id = e.employee_id
      INNER JOIN teacher_class_room_course tcrc ON ep.employee_id = tcrc.teacher_id
      AND crt.class_room_id IN (#{class_room_ids}) AND #{gender_conditions} AND tcrc.course_id IN (#{course_ids})")
    return class_room_teachers
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
