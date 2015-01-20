class AttendanceController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all)
    render :layout => false
  end

  def class_room_register
    class_room_id = params[:class_room_id]
    @class_rooms = ClassRoom.find(:all)
    @students = Student.find_by_sql("SELECT * FROM class_room c INNER JOIN class_room_student crs
      ON c.class_room_id=crs.class_room_id INNER JOIN student s ON crs.student_id=s.student_id
      WHERE c.class_room_id=#{class_room_id}")
    
    render :layout => false
  end
end
