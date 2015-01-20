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

  def create_daily_attendance_register
    student_params = []
    params.each do |p|
      student_params << p if p.to_s.match(/student/i)
    end

    class_room_id = params[:class_room_id]
    attendance_date = params[:attendance_date].to_date
    
    ActiveRecord::Base.transaction do
      repeat_student_attendances = StudentAttendance.find_by_sql("SELECT * FROM student_attendance sa INNER JOIN class_room_student crs
        ON sa.student_id=crs.student_id INNER JOIN class_room cr ON crs.class_room_id=cr.class_room_id
        WHERE cr.class_room_id=#{class_room_id} AND sa.date='#{attendance_date}'")
      
      (repeat_student_attendances || []).each do |rsa|
        rsa.delete
      end
      
      (student_params || []).each do |key, status|
          student_id = key.split('_').last
          StudentAttendance.create({
            :date => attendance_date.to_date,
            :student_id => student_id,
            :status => status
          })
      end
    end

    flash[:notice] = "Operation successful"
    redirect_to :controller => "attendance", :action => "index" and return
  end

  def load_attendance_data
    class_room_id = params[:class_room_id]
    attendance_date = params[:attendance_date].to_date
    attendance_hash = {}
    students = Student.find_by_sql("SELECT * FROM class_room c INNER JOIN class_room_student crs
      ON c.class_room_id=crs.class_room_id INNER JOIN student s ON crs.student_id=s.student_id
      INNER JOIN student_attendance sa ON s.student_id=sa.student_id
      WHERE c.class_room_id=#{class_room_id} AND sa.date='#{attendance_date}'")
    
    (students || []).each do |student|
      student_id = student.student_id
      attendance_hash[student_id] = student.status #Attendance Status
    end

    render :text => attendance_hash.to_json and return
  end
  
end
