class Course < ActiveRecord::Base
  set_table_name :course
	set_primary_key :course_id

  has_many :class_room_courses

  def self.total_teachers(class_room_id, course_id)
    teacher_class_room_course_count = TeacherClassRoomCourse.find(:all,
      :conditions => ["class_room_id =? AND course_id =?", class_room_id, course_id]).count
    return teacher_class_room_course_count
  end
  
end
