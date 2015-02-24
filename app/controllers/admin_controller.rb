class AdminController < ApplicationController
  def home
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
  end

  def load_enrollment_by_gender_data
    if (request.method == :post)
      year = params[:year]
      enrollment_data = {}
      males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{year}").count

      females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{year}").count

      enrollment_data["males"] = males
      enrollment_data["females"] = females
      enrollment_data["year"] = year
      render :text => enrollment_data.to_json and return
    end
  end
  
  def school_enrollment

  end

  def students_statistics
    start_year = Date.today.year - 5 #This needs to be reworked.
    end_year = Date.today.year

    enrollment_data = {}

    (start_year..end_year).to_a.each do |year|
      students = Student.find_by_sql("SELECT * FROM student WHERE DATE_FORMAT(created_at, '%Y') = #{year}")
      enrollment_data[year] = {}
      enrollment_data[year] = students.count
    end

    @years = []
    @enrollments = []

    enrollment_data.sort_by{|year, count|year.to_i}.each do |key, total|
      @years << key
      @enrollments << total
    end

  end

  def teachers_statistics
    start_year = Date.today.year - 5 #This needs to be reworked.
    end_year = Date.today.year

    enrollment_data = {}

    (start_year..end_year).to_a.each do |year|
      teachers = Teacher.find_by_sql("SELECT * FROM teacher WHERE DATE_FORMAT(created_at, '%Y') = #{year}")
      enrollment_data[year] = {}
      enrollment_data[year] = teachers.count
    end

    @dates = []
    @enrollments = []

    enrollment_data.sort_by{|year, count|year.to_i}.each do |key, total|
      @dates << key
      @enrollments << total
    end

    
  end
  
  def daily_attendance
    week_day_start = Date.today.beginning_of_week #Monday
    week_day_end = week_day_start + 4.days

    @week_day_start = week_day_start.strftime("%d-%b-%Y")
    @week_day_end = week_day_end.strftime("%d-%b-%Y")

    @periods = [
      ['This Week','this_week'],
      ['This Month', 'this_month'],
      ['This Year', 'this_year'],
      ['Custom Date','custom_date']
    ]
    attendance_data = {}

    (week_day_start..week_day_end).to_a.each do |date|
      date = date.to_s
      available = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_attendance sa ON
        s.student_id = sa.student_id AND DATE(sa.date) = '#{date}' and sa.status='P'")
      attendance_data[date] = {}

      not_available = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_attendance sa ON
        s.student_id = sa.student_id AND DATE(sa.date) = '#{date}' and sa.status='A'")

      attendance_data[date]["P"] = available.count
      attendance_data[date]["A"] = not_available.count
    end

    @weekly_dates = []
    @weekly_attendances = []
    @weekly_absenteeism = []

    attendance_data.sort_by{|date, data|date.to_date}.each do |key, values|
      @weekly_dates << key.to_date.strftime("%d/%b")
      @weekly_attendances << values["P"]
      @weekly_absenteeism << values["A"]
    end

    
  end

  def load_daily_attendance_data
    if (params[:period] == 'this_week')
      start_date = Date.today.beginning_of_week
      end_date = start_date + 4.days
    end

    if (params[:period] == 'this_month')
      start_date = Date.today.beginning_of_month
      end_date = Date.today
    end

    if (params[:period] == 'this_year')
      start_date = Date.today.beginning_of_year
      end_date = Date.today
    end
    
    if (params[:period] == 'custom_date')
      start_date = params[:start_date].to_date
      end_date = params[:end_date].to_date
    end
    

    attendance_data = {}

    (start_date..end_date).to_a.each do |date|
      next if date.strftime("%A").match(/SATURDAY|SUNDAY/i) #Skip Saturdays and Sundays
      date = date.to_s
      attendance_data[date] = {}
      available = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_attendance sa ON
        s.student_id = sa.student_id AND DATE(sa.date) = '#{date}' and sa.status='P'")
      
      not_available = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_attendance sa ON
        s.student_id = sa.student_id AND DATE(sa.date) = '#{date}' and sa.status='A'")

      attendance_data[date]["P"] = available.count
      attendance_data[date]["A"] = not_available.count
    end

    attendance_hash = {}
    daily_dates = []
    daily_attendances = []
    daily_absenteeism = []

    attendance_data.sort_by{|date, data|date.to_date}.each do |key, values|
      daily_dates << key.to_date.strftime("%d/%b")
      daily_attendances << values["P"]
      daily_absenteeism << values["A"]
    end
    
    attendance_hash["daily_dates"] = daily_dates
    attendance_hash["daily_attendances"] = daily_attendances
    attendance_hash["daily_absenteeism"] = daily_absenteeism
    attendance_hash["start_date"] = start_date.strftime("%d-%B-%Y")
    attendance_hash["end_date"] = end_date.strftime("%d-%B-%Y")
    
    render :text => attendance_hash.to_json and return
  end
  
  def page_full_width
    
  end
  
  def page_other
    
  end

  def dashboard
    
  end

  def settings
    @school_name = GlobalProperty.find_by_property("school_name") rescue nil
    
  end

  def index
    
  end

  def time_table
    
  end

  def research
    
  end

  def add_property
    school_name = GlobalProperty.find_by_property("school_name")
    if school_name.blank?
      GlobalProperty.create(:property => 'school_name',
        :value => params[:school_name])
    else
      school_name.value = params[:school_name]
      school_name.save
    end
    flash[:notice] = "Operation successful"
    redirect_to :controller => "admin", :action => "settings"
  end
  
  def semester_settings
    
  end

  def set_total_semesters
    
  end

  def set_current_semester
    
  end

  def view_semesters
    
  end

  def time_table_management_menu
    
  end

  def subject_groups_management
    @class_rooms = ClassRoom.find(:all).map(&:name)
    @class_room_courses = []

    class_rooms = ClassRoom.find(:all)
    (class_rooms || []).each do |class_room|
      total_courses = class_room.class_room_courses.count
      @class_room_courses << total_courses
    end
    
    
  end

  def semester_management_menu
    @current_year = Date.today.year
    @current_semester = GlobalProperty.find_by_property("current_semester").value rescue nil
    @current_semester_start_date = GlobalProperty.find_by_property("current_semester_start_date").value rescue nil
    @current_semester_end_date = GlobalProperty.find_by_property("current_semester_end_date").value rescue nil
    
  end

  def payments_overview_menu
    
  end

  def print_teacher_time_table
    
  end

  def documents_management_menu
    
  end

  def barcode_scanning_menu
    
  end

  def system_configuration_menu
    
  end

  def backup_data_menu
    
  end

  def time_table_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def subject_groups_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def semester_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def payments_overview_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def print_teacher_time_table_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def documents_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def barcode_scanning_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def system_configuration_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def backup_data_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def class_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def document_types_menu
    
  end

  def add_logo
    @school_logo = GlobalProperty.find_by_property('school_logo')
    if (request.method == :post)
      unless params[:attachment].content_type.match(/IMAGE/i)
        flash[:error] = "File format not supported. Try another image if at all it was an image"
        redirect_to :controller => :admin, :action => :add_logo and return
      end
      logo = GlobalProperty.new
      current_logo = GlobalProperty.find_by_property('school_logo')
      logo = current_logo unless current_logo.blank?
      logo.uploaded_file = params[:attachment]
      logo.property = 'school_logo'
      if logo.save
        flash[:notice] = "You have successfully uploaded your logo"
        redirect_to :controller => :admin, :action => :add_logo and return
      else
        flash[:error] = "There was a problem submitting your attachment. Check for errors and try again"
        redirect_to :controller => :attachments, :action => :upload_document and return
      end
    end
    
  end

  def code_logo
    @school_logo = GlobalProperty.find_by_property('school_logo')
    send_data @school_logo.data, :filename => @school_logo.property, :disposition => "inline"
  end

  def school_logo
    school_logo = GlobalProperty.find_by_property('school_logo')
    unless school_logo.blank?
      send_data school_logo.data, :filename => school_logo.property, :disposition => "inline" and return
    end
  end
  
end
