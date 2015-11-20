class SemestersController < ApplicationController
  def index
    @current_year = Date.today.year
    @current_semester = GlobalProperty.find_by_property("current_semester").value rescue 'Not Set'
    @current_semester_start_date = GlobalProperty.find_by_property("current_semester_start_date").value rescue 'Not Set'
    @current_semester_end_date = GlobalProperty.find_by_property("current_semester_end_date").value rescue 'Not Set'
    
  end

  def semester_settings
    semesters = Semester.all
    @total_semesters = semesters.count
    @semesters = semesters
  end

  def set_total_semesters
     
  end

  def set_current_semester
    @total_semesters = Semester.all.count
    @current_semester_number = Semester.current_semester_number #Returns digit e.g 1, 2, 3, 4
    @semesters = Semester.find(:all)
    if (request.method == :post)
      SemesterAudit.set_current_semester(params[:semester_id])
      render :text => "true and return"
    end
    
  end

  def set_semester_dates
    @semesters = Semester.find(:all)
    if (request.method == :post)
      errors = ""
      tab = '&nbsp;' * 10
      params[:semesters].each do |semester_id, dates|
        semester = Semester.find(semester_id)
        start_date = dates[:start_date].to_date rescue nil
        end_date = dates[:end_date].to_date rescue nil
        error_header = true
        if (!start_date.blank? && !end_date.blank?)
          if start_date == end_date
            if error_header
              errors += "<b>Semester #{semester.semester_number}</b><br />"
              error_header = false
            end
            errors += "#{tab}has start date = end_date<br />"
          end
          if start_date > end_date
            if error_header
              errors += "<b>Semester #{semester.semester_number}</b><br />"
              error_header = false
            end
            errors += "#{tab}has start date > end_date<br />"
          end
        else
          if error_header
            errors += "<b>Semester #{semester.semester_number}</b><br />"
            error_header = false
          end
          errors += "#{tab}has no start date <br />" if start_date.blank?
          errors += " #{tab}has no end date <br />" if end_date.blank?
        end
      end
      unless errors.blank?
        flash[:error] = errors
        redirect_to :controller => "semesters", :action => "set_semester_dates" and return
      else
        params[:semesters].each do |semester_id, dates|
          start_date = dates[:start_date].to_date
          end_date = dates[:end_date].to_date
          
          #Semester Audit States: Initial, New, Open, Close
          SemesterAudit.initial_semester(semester_id, start_date, end_date)
          SemesterAudit.new_semester(semester_id, start_date, end_date)

        end
        
        flash[:notice] = "Operation successful"
        redirect_to :controller => "semesters", :action => "set_semester_dates" and return
      end
    end
  end
  
  def view_semesters
    @semesters = Semester.find(:all)
    @current_semester = Semester.current
  end

  def load_semester_data
    year = params[:year]
    semesters = Semester.find(:all)
    @hash = {}
    (semesters || []).each do |semester|
      semester_id = semester.id
      @hash[semester_id] = {}
      class_room_students = ClassRoomStudent.find(:all, :joins => [:class_room],
        :conditions => ["semester_id =? AND year=?", semester_id, year])
      class_room_students.each do |crs|
        next if crs.class_room.blank?
        class_room_id = crs.class_room.id
        @hash[semester_id][class_room_id] = {} if @hash[semester_id][class_room_id].blank?
        total_students_per_class = ClassRoomStudent.find(:all, :conditions => ["semester_id =? AND class_room_id =?",
            semester_id, class_room_id])

        total_males = 0
        total_females = 0
        (total_students_per_class || []).each do |crs|
          next if crs.student.blank?
          if (crs.student.gender.upcase == 'MALE')
            total_males += 1
          end
          if (crs.student.gender.upcase == 'FEMALE')
            total_females += 1
          end
        end

        @hash[semester_id][class_room_id]["total_students"] = total_students_per_class.count
        @hash[semester_id][class_room_id]["males"] = total_males
        @hash[semester_id][class_room_id]["females"] = total_females
      end
    end

    render :text => @hash.to_json and return
  end

  def create_semester
    total_semesters = params[:total_semesters].to_i

    ActiveRecord::Base.transaction do
      (1..total_semesters).each do |semester|
        Semester.create_new_semester(semester)
      end
    end
    
    flash[:notice] = "Operation successful"
    redirect_to :controller =>"semesters",:action => "set_semester_dates" and return
  end

  def edit_semester_audit
    semester = Semester.find(params[:semester_id])
    start_date = semester.start_date
    end_date = semester.end_date
    @semester = semester
    @semesters = Semester.all
    
    if request.method == :post
 
      new_start_date = params[:start_date]
      new_end_date = params[:end_date]

      unless (start_date.blank? || end_date.blank?)
        semester_audit = SemesterAudit.find(:last, :conditions => ["semester_id =? AND start_date =? AND
          end_date=?", params[:semester_id], start_date, end_date]
        )
      else
        semester_audit = SemesterAudit.find(:last, :conditions => ["semester_id =? AND
          (start_date IS NULL OR end_date IS NULL)", params[:semester_id]]
        )
      end
      
      semester_audit.start_date = new_start_date
      semester_audit.end_date = new_end_date
      semester_audit.save

      initial_semester_audit = SemesterAudit.find(:last, :conditions => ["semester_id =? AND state =? AND
        (start_date IS NULL OR end_date iS NULL)", params[:semester_id], 'initial'])
      
      unless initial_semester_audit.blank?
        #Update initial record. For other reasons it might have null values of start and end_date fields
        initial_semester_audit.start_date = new_start_date
        initial_semester_audit.end_date = new_end_date
        initial_semester_audit.save
      end

      redirect_to ("/semesters/set_semester_dates") and return
    end

  end

  def add_new_semester
    semester = Semester.create_new_semester_without_parameter
    redirect_to ("/semesters/edit_semester_audit?semester_id=#{semester.semester_id}") and return
  end
  
end
