class SemestersController < ApplicationController
  def index
    @current_year = Date.today.year
    @current_semester = GlobalProperty.find_by_property("current_semester").value rescue 'Not Set'
    @current_semester_start_date = GlobalProperty.find_by_property("current_semester_start_date").value rescue 'Not Set'
    @current_semester_end_date = GlobalProperty.find_by_property("current_semester_end_date").value rescue 'Not Set'
    
  end

  def semester_settings
    @total_semesters = Semester.all.count   
  end

  def set_total_semesters
     
  end

  def set_current_semester
    @total_semesters = Semester.all.count
    if (request.method == :post)
      current_semester = params[:semester]
      current_semester_start_date = params[:start_date]
      current_semester_end_date = params[:end_date]

      ActiveRecord::Base.transaction do
        cs = GlobalProperty.find_by_property("current_semester")
        cs.delete unless cs.blank?

        cssd = GlobalProperty.find_by_property("current_semester_start_date")
        cssd.delete unless cssd.blank?

        csed = GlobalProperty.find_by_property("current_semester_end_date")
        csed.delete unless csed.blank?
        
        GlobalProperty.create({:property => "current_semester", :value => current_semester})
        GlobalProperty.create({:property => "current_semester_start_date",:value => current_semester_start_date})
        GlobalProperty.create({:property => "current_semester_end_date",:value => current_semester_end_date})
      end

      flash[:notice] = "Operation successful"
      redirect_to :action => "index" and return
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
        flash[:notice] = "No errors found"
      end
    end
  end
  
  def view_semesters
    semesters = Semester.find(:all)
    @class_room_hash = {}
    start_year = (Date.today.year - 5)
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end

    @hash = {}
    (semesters || []).each do |semester|
      semester_id = semester.id
      @hash[semester_id] = {}
      class_room_students = ClassRoomStudent.find(:all, :conditions => ["semester_id =?", semester_id])
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
      Semester.delete_all
      (1..total_semesters).each do |semester|
        Semester.create({
            :semester_number => semester
          })
      end
    end
    
    flash[:notice] = "Operation successful"
    redirect_to :action => "index" and return
  end

end
