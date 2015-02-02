class AdminController < ApplicationController
  def home
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
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
    render :layout => false
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
    
    render :layout => false
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

    render :layout => false
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

    render :layout => false
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
    render :layout => false
  end
  
  def page_other
    render :layout => false
  end

  def dashboard
    render :layout => false
  end

  def settings
    @settings = school_setting
    render :layout => false
  end

  def index
    render :layout => false
  end

  def time_table
    render :layout => false
  end

  def research
    render :layout => false
  end

  def add_property
    g = GlobalProperty.find_by_property("#{params[:name]}")
    if g.blank?
      GlobalProperty.create(:property => params[:name],
        :value => params[:value])
    else
      g.value = params[:value]
      g.save
    end
    render :text => g.to_json
  end
  
  def semester_settings
    render :layout => false
  end

  def set_total_semesters
    render :layout => false
  end

  def set_current_semester
    render :layout => false
  end

  def view_semesters
    render :layout => false
  end

  def time_table_management_menu
    render :layout => false
  end

  def subject_groups_management
    @class_rooms = ClassRoom.find(:all).map(&:name)
    @class_room_courses = []

    class_rooms = ClassRoom.find(:all)
    (class_rooms || []).each do |class_room|
      total_courses = class_room.class_room_courses.count
      @class_room_courses << total_courses
    end
    
    render :layout => false
  end

  def semester_management_menu
    @current_year = Date.today.year
    @current_semester = GlobalProperty.find_by_property("current_semester").value rescue nil
    @current_semester_start_date = GlobalProperty.find_by_property("current_semester_start_date").value rescue nil
    @current_semester_end_date = GlobalProperty.find_by_property("current_semester_end_date").value rescue nil
    render :layout => false
  end

  def payments_overview_menu
    render :layout => false
  end

  def print_teacher_time_table
    render :layout => false
  end

  def documents_management_menu
    render :layout => false
  end

  def barcode_scanning_menu
    render :layout => false
  end

  def system_configuration_menu
    render :layout => false
  end

  def backup_data_menu
    render :layout => false
  end

  def time_table_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def subject_groups_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def semester_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def payments_overview_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def print_teacher_time_table_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def documents_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end
end
