class AttendanceController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all)
    week_day_start = Date.today.beginning_of_week #Monday
    week_day_end = week_day_start + 4.days
    
    @week_day_start = week_day_start.strftime("%d-%b-%Y")
    @week_day_end = week_day_end.strftime("%d-%b-%Y")
    
    attendance_data = {}
    (week_day_start..week_day_end).to_a.each do |date|
        attendance_data[date.to_date.to_s] = {}
    end

    (week_day_start..week_day_end).to_a.each do |date|
      date = date.to_s
      students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_attendance sa ON
        s.student_id = sa.student_id AND DATE(sa.date) = '#{date}'")
      attendance_data[date] = students.count
    end
    
    @weekly_dates = []
    @weekly_attendances = []
    
    attendance_data.sort_by{|date, count|date.to_date}.each do |key, value|
      @weekly_dates << key.to_date.strftime("%d/%b")
      @weekly_attendances << value
    end

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
