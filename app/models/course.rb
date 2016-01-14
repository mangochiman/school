class Course < ActiveRecord::Base
  set_table_name :course
	set_primary_key :course_id

  has_many :class_room_courses

  def self.total_teachers(class_room_id, course_id)
=begin
    teacher_class_room_course_count = TeacherClassRoomCourse.find(:all,
      :conditions => ["class_room_id =? AND course_id =?", class_room_id, course_id]).count
=end
     teacher_class_room_course_count = Employee.find_by_sql("SELECT e.* FROM teacher_class_room_course tcrc
      INNER JOIN course c ON tcrc.course_id = c.course_id AND tcrc.class_room_id=#{class_room_id}
      INNER JOIN employee e ON tcrc.teacher_id = e.employee_id WHERE c.course_id=#{course_id}").count
    
    return teacher_class_room_course_count
  end
  
end
