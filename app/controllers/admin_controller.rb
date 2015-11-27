class AdminController < ApplicationController
  skip_before_filter :authenticate_user, :only => [:school_logo]
  def home
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
  end

  def load_enrollment_by_gender_data
    if (request.method == :post)
      semester_audit_id = params[:semester_audit_id]
      enrollment_data = {}
      males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

      females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count

      semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
      enrollment_data["males"] = males
      enrollment_data["females"] = females
      enrollment_data["semester_data"] = semester_data
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
    @current_semester = Semester.current_semester_number
    @current_semester = 'Not Set' if @current_semester.blank?
    @current_semester_start_date = Semester.current_semester_start_date
    @current_semester_start_date = 'Not Set' if @current_semester_start_date.blank?
    @current_semester_end_date = Semester.current_semester_end_date
    @current_semester_end_date = 'Not Set' if @current_semester_end_date.blank?
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
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    @current_semester_audit_id = (semester_audit_id rescue 0)
    
    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def subject_groups_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def semester_management_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    @current_semester_audit_id = (semester_audit_id rescue 0)
    
    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def payments_overview_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def print_teacher_time_table_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def documents_management_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def barcode_scanning_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
  end

  def system_configuration_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def backup_data_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    @current_semester_audit_id = (semester_audit_id rescue 0)
    
    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def class_management_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    @current_semester_audit_id = (semester_audit_id rescue 0)
    
    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
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

  def search_everything
    first_name = params[:first_name]
    last_name = params[:last_name]
    students = Student.find(:all, :conditions => ["fname LIKE ? AND lname LIKE ?",
        '%' + first_name + '%', '%' + last_name + '%'])
    
    teachers = Teacher.find(:all, :conditions => ["fname LIKE ? AND lname LIKE ?",
        '%' + first_name + '%', '%' + last_name + '%'])

    guardians = Parent.find(:all, :conditions => ["fname LIKE ? AND lname LIKE ?",
        '%' + first_name + '%', '%' + last_name + '%'])
    hash = {}
    hash["students"] = {}
    hash["teachers"] = {}
    hash["guardians"] = {}
    
    students.each do |student|
      student_id = student.id
      hash["students"][student_id] = {}
      hash["students"][student_id]["fname"] = student.fname.upcase
      hash["students"][student_id]["lname"] = student.lname.upcase
    end
    
    teachers.each do |teacher|
      teacher_id = teacher.id
      hash["teachers"][teacher_id] = {}
      hash["teachers"][teacher_id]["fname"] = teacher.fname.upcase
      hash["teachers"][teacher_id]["lname"] = teacher.lname.upcase
    end

    guardians.each do |guardian|
      guardian_id = guardian.id
      hash["guardians"][guardian_id] = {}
      hash["guardians"][guardian_id]["fname"] = guardian.fname.upcase
      hash["guardians"][guardian_id]["lname"] = guardian.lname.upcase
    end

    render :text => hash.to_json and return
  end

  def period_settings
    @start_time = [['Select Time', ''], ['7:00 AM', '7:00'], ['7:30 AM', '7:30'], ['7:40 AM', '7:40'],['7:45 AM', '7:45'],
      ['8:00 AM', '8:00'], ['8:30 AM', '8:30'], ['8:40 AM', '8:40'], ['8:45 AM', '8:45'],
      ['9:00 AM', '9:00'], ['9:30 AM', '9:30'], ['9:40 AM', '9:40'], ['9:45 AM', '9:45'],
      ['10:00 AM', '10:00'], ['10:30 AM', '10:30'], ['10:40 AM', '10:40'], ['10:45 AM', '10:45']
    ]

    @end_time = [['12:00 AM', '12:00'], ['12:30 AM', '12:30'], ['12:40 AM', '12:40'],['12:45 AM', '12:45'],
      ['01:00 PM', '13:00'], ['01:30 PM', '13:30'], ['01:40 PM', '13:40'], ['01:45 PM', '13:45'],
      ['02:00 PM', '14:00'], ['02:30 PM', '14:30'], ['02:40 PM', '14:40'], ['02:45 PM', '14:45'],
      ['03:00 PM', '15:00'], ['03:30 PM', '15:30'], ['03:40 PM', '15:40'], ['03:45 PM', '15:45'],
      ['04:00 PM', '16:00'], ['04:30 PM', '16:30'], ['04:40 PM', '16:40'], ['04:45 PM', '16:45'],
      ['05:00 PM', '17:00'], ['05:30 PM', '17:30'], ['05:40 PM', '17:40'], ['05:45 PM', '17:45'],
      ['Select Time', '']
    ].reverse
    
    @period_length = [['Select Duration', ''], ['10 Min', '10'], ['15 Min', '15'], ['20 Min', '20'], ['25 Min', '25'], 
      ['30 Min', '30'], ['45 Min', '45'],['50 Min', '50'], ['1 Hr', '60'], ['1Hr 15Min', '75'], ['1 Hr 30 Min', '90'],
      ['2Hr', '120']
    ]

    @lunch_start_time = [['Select Time' , ''], ['10:30 AM', '10:30'], ['10:45 AM', '10:45'],
      ['11:00 AM', '11:00'],['11:30 AM', '11:30'], ['11:45 AM', '11:45'], ['12:00 Noon', '12:00'],
      ['12:30 PM', '12:30'], ['12:45 PM', '12:45'], ['1:00 PM', '13:00'],['01:30 PM', '13:30'],
      ['1:45 PM', '13:45'], ['02:00 PM', '14:00']
    ]

    @lunch_period_length = [['Select Duration', ''], ['15 Min', '15'], ['30 Min', '30'], ['45 Min', '45'], ['1 Hr', '60'],
      ['1Hr 30 Min', '90']
    ]

    @current_period_start_time = GlobalProperty.find_by_property("period_start_time").value rescue ''
    @current_period_end_time = GlobalProperty.find_by_property("period_end_time").value rescue ''
    @current_period_length = GlobalProperty.find_by_property("period_length").value rescue ''
    @current_lunch_start_time = GlobalProperty.find_by_property("lunch_start_time").value rescue ''
    @current_lunch_period_length = GlobalProperty.find_by_property("lunch_period_length").value rescue ''
    
  end

  def course_settings
    @min_periods_per_week = GlobalProperty.find_by_property("min_periods_per_week").value rescue ''
    @max_periods_per_week = GlobalProperty.find_by_property("max_periods_per_week").value rescue ''
    @recommended_periods_per_week = GlobalProperty.find_by_property("recommended_periods_per_week").value rescue ''
  end

  def teacher_settings
    @teacher_min_periods_per_week = GlobalProperty.find_by_property("teacher_min_periods_per_week").value rescue ''
    @teacher_max_periods_per_week = GlobalProperty.find_by_property("teacher_max_periods_per_week").value rescue ''
    @teacher_recommended_periods_per_week = GlobalProperty.find_by_property("teacher_recommended_periods_per_week").value rescue ''
    @teacher_max_courses_per_row = GlobalProperty.find_by_property("teacher_max_courses_per_row").value rescue ''
    @teacher_min_courses_per_day = GlobalProperty.find_by_property("teacher_min_courses_per_day").value rescue ''
    @teacher_max_courses_per_day = GlobalProperty.find_by_property("teacher_max_courses_per_day").value rescue ''
  end

  def class_bock_settings
    
  end

  def view_time_table
    
  end
  
end
