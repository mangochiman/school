class ClassRoomController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all).map(&:name)

    @totals = []
    @males = []
    @females = []

    class_rooms = ClassRoom.find(:all)
    hash = {}

    (class_rooms || []).each do |class_room|
      total_students = class_room.active_student_class_room_adjustments.count
      class_room_id = class_room.id
      hash[class_room_id] = {}
      hash[class_room_id]["total_students"] = total_students
      total_males = 0
      total_females = 0

      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        if (crs.student.gender.upcase == 'MALE')
          total_males += 1
        end
        if (crs.student.gender.upcase == 'FEMALE')
          total_females += 1
        end
      end
      hash[class_room_id]["total_males"] = total_males
      hash[class_room_id]["total_females"] = total_females
    end

    @statistics = hash.sort_by{|key, value|key.to_i}

    @statistics.each do |key, value|
      @males << value["total_males"]
      @females << value["total_females"]
      @totals << value["total_students"]
    end

    
  end

  def add_class
    @class_rooms = ClassRoom.find(:all)
  end

  def edit_class
    @class_rooms = ClassRoom.all   
  end

  def edit_me
    @class_room = ClassRoom.find(params[:class_room_id])
    @class_rooms = ClassRoom.find(:all)
    if request.method == :post
      if (@class_room.update_attributes({
              :name => params[:class_name],
              :code => params[:code]
            }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :action => "edit_class" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :action => "edit_class" and return
      end
    end
    
  end
  def remove_class
    @class_rooms = ClassRoom.all
    
  end

  def delete_class_rooms
    if (params[:mode] == 'single_entry')
      class_room = ClassRoom.find(params[:class_room_id])
      class_room.delete
      render :text => "true" and return
    end

    class_room_ids = params[:class_room_ids].split(",")
    
    (class_room_ids || []).each do |class_room_id|
      class_room = ClassRoom.find(class_room_id)
      class_room.delete
    end
    
    render :text => "true" and return
  end
  
  def assign_subjects
    @class_rooms = ClassRoom.all
    
  end

  def assign_me_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = Course.all
    @my_courses = []
    (@class_room.class_room_courses || []).each do |cc|
      @my_courses << cc.course
    end
    unless (@class_room.class_room_courses.blank?)
      assigned_course_ids = @class_room.class_room_courses.collect{|c| c.course_id}
      @courses = Course.find(:all, :conditions => ["course_id NOT IN (?)", assigned_course_ids] )
    end

    if (request.method == :post)
      (params[:subjects] || []).each do |course, details|
        course_id = Course.find_by_name(course).id
        ClassRoomCourse.create({
            :class_room_id => params[:class_room_id],
            :course_id => course_id
          })
      end
      flash[:notice] = "You have successfuly assigned courses"
      redirect_to :controller => "class_room", :action => "assign_me_teachers", :class_room_id => params[:class_room_id] and return
      #redirect_to :action => "assign_me_subjects", :class_room_id => params[:class_room_id] and return
    end
    
  end
  
  def edit_subjects
    @class_rooms = ClassRoom.all
    
  end
  
  def edit_my_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @all_courses = Course.all
    @assigned_courses = []
    
    unless (@class_room.class_room_courses.blank?)
      @assigned_courses = @class_room.class_room_courses.collect{|c| c.course}
      #@assigned_courses = Course.find(:all, :conditions => ["course_id IN (?)", assigned_course_ids] )
    end
    if (request.method == :post)
      ActiveRecord::Base.transaction do
        @class_room.class_room_courses.delete_all

        (params[:subjects] || []).each do |course, details|
          course_id = Course.find_by_name(course).id
          ClassRoomCourse.create({
              :class_room_id => params[:class_room_id],
              :course_id => course_id
            })
        end
        flash[:notice] = "You have successfuly edited courses"
        redirect_to :action => "edit_my_subjects", :class_room_id => params[:class_room_id] and return
      end
    end
    
  end
  
  def assign_teacher
    @class_rooms = ClassRoom.all
    
  end

  def assign_me_teachers
    @class_room = ClassRoom.find(params[:class_room_id])
    @teachers = Teacher.all
    
    @class_room_teachers = []
    @class_room.class_room_teachers.each do |crt|
      @class_room_teachers << crt.teacher
    end
    
    unless (@class_room.class_room_teachers.blank?)
      assigned_teacher_ids = @class_room.class_room_teachers.collect{|t| t.teacher_id}
      @teachers = Teacher.find(:all, :conditions => ["teacher_id NOT IN (?)", assigned_teacher_ids] )
    end
    
    if (request.method == :post)

      (params[:teachers] || []).each do |teacher_id, details|
        ClassRoomTeacher.create({
            :class_room_id => params[:class_room_id],
            :teacher_id => teacher_id
          })
      end
      
      flash[:notice] = "You have successfuly assigned teachers"
      redirect_to :controller => "class_room", :action => "index" and return
      #redirect_to :action => "assign_me_teachers", :class_room_id => params[:class_room_id] and return
    end
    
  end
  
  def edit_teacher
    @class_rooms = ClassRoom.all
    
  end

  def edit_my_teachers
    @class_room = ClassRoom.find(params[:class_room_id])
    @all_teachers = Teacher.all
    @assigned_teachers = []

    unless (@class_room.class_room_teachers.blank?)
      @assigned_teachers = @class_room.class_room_teachers.collect{|c| c.teacher}
      #@assigned_courses = Course.find(:all, :conditions => ["course_id IN (?)", assigned_course_ids] )
    end
    if (request.method == :post)
      ActiveRecord::Base.transaction do
        #@class_room.class_room_courses.delete_all
        assigned_teacher_ids = @assigned_teachers.map(&:teacher_id)
        already_signed_teacher_ids = []
        
        (params[:teachers] || []).each do |teacher_id, details|
          if (assigned_teacher_ids.include?(teacher_id.to_i))
            already_signed_teacher_ids << teacher_id.to_i
            next
          end
          ClassRoomTeacher.create({
              :class_room_id => params[:class_room_id],
              :teacher_id => teacher_id
            })
        end
        
        ((assigned_teacher_ids - already_signed_teacher_ids) || []).each do |teacher_id|
          class_room_teacher = @class_room.class_room_teachers.find(:last,
            :conditions => ["teacher_id =?", teacher_id])
          class_room_teacher.delete
        end
      
        flash[:notice] = "You have successfuly edited teachers"
        redirect_to :action => "edit_my_teachers", :class_room_id => params[:class_room_id] and return
      end
    end
    
  end
  
  def create_class_rooms
    class_name = params[:class_name]
    code = params[:code]
    class_name_exists = ClassRoom.find_by_name(params[:class_name])
    if (class_name_exists)
      flash[:error] = "Unable to save. Class room <b>#{params[:class_name]} already exists</b>"
      redirect_to :controller => "class_room", :action => "add_class" and return
    end
    class_room = ClassRoom.create({
        :code => code,
        :name => class_name
      })
    if (class_room)
      flash[:notice] = "You have successfully created classroom"
      redirect_to :controller => "class_room", :action => "assign_me_subjects", :class_room_id => class_room.class_room_id and return
      #redirect_to :action => "add_class" and return
    else
      flash[:error] = "Operation not successful. Check for errors and try again"
      render :action => "add_class" and return
    end
  end

  def view_classes
    @class_rooms = ClassRoom.all
    
  end
  
  def render_courses
    class_room_id = params[:class_room_id]
    class_room_courses = ClassRoom.find(class_room_id).class_room_courses
    class_name = ClassRoom.find(class_room_id).name
    course_names = {}

    (class_room_courses || []).each do |crc|
      course_names[class_name] = [] if course_names[class_name].blank?
      course_names[class_name] << crc.course.name
    end

    if class_room_courses.blank?
      course_names[class_name] = []
    end
    
    render :json => course_names.first and return
  end

  def render_students
    class_room_id = params[:class_room_id]
    class_room_students = ClassRoom.find(class_room_id).class_room_students
    class_name = ClassRoom.find(class_room_id).name
    student_data = {}
    (class_room_students || []).each do |crs|
      next if crs.student.blank?
      student_name = (crs.student.fname.to_s + ' ' + crs.student.lname.to_s)
      gender = crs.student.gender.first.capitalize.to_s
      gender = '??' if gender.blank?
      student_data[class_name] = [] if student_data[class_name].blank?
      student_data[class_name] << student_name + ' (' + gender + ')'.to_s
    end

    if (class_room_students.blank?)
      student_data[class_name] = []
    end
    
    render :json => student_data.first and return
  end

  def render_teachers
    class_room_id = params[:class_room_id]
    class_room_teachers = ClassRoom.find(class_room_id).class_room_teachers
    class_name = ClassRoom.find(class_room_id).name
    teacher_data = {}
    
    (class_room_teachers || []).each do |crt|
      teacher_name = crt.teacher.fname.to_s + ' ' + crt.teacher.lname.to_s
      gender = crt.teacher.gender.first.capitalize.to_s rescue "??"
      teacher_data[class_name] = [] if teacher_data[class_name].blank?
      teacher_data[class_name] << teacher_name + ' (' + gender + ')'.to_s
    end

    if (class_room_teachers.blank?)
      teacher_data[class_name] = []
    end
    
    render :json => teacher_data.first and return
  end

  def search_class_rooms
    class_room_name = params[:class_room_name]
    hash = {}
    class_rooms = ClassRoom.find_by_sql("SELECT * FROM class_room WHERE name LIKE '%#{class_room_name}%'")

    class_rooms.each do |class_room|
      class_room_id = class_room.class_room_id
      hash[class_room_id] = {}
      hash[class_room_id]["class_room_name"] = class_room.name.titleize
      hash[class_room_id]["code"] = class_room.code
      hash[class_room_id]["total_courses"] = class_room.class_room_courses.count
      hash[class_room_id]["total_students"] = class_room.class_room_students.count
      hash[class_room_id]["total_teachers"] = class_room.class_room_teachers.count
      hash[class_room_id]["date_created"] = class_room.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end

  def switch_class_room_menu
    @class_room = ClassRoom.find(params[:class_room_id])
  end
  
end
