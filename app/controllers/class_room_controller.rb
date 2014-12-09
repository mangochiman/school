class ClassRoomController < ApplicationController
  def index
    render :layout => false
  end

  def add_class
    render :layout => false
  end

  def edit_class
    @class_rooms = ClassRoom.all
    render :layout => false
  end

  def edit_me
    @class_room = ClassRoom.find(params[:class_room_id])
    if request.method == :post
      if (@class_room.update_attributes({
          :name => params[:class_name],
          :year => params[:year],
          :grade => params[:grade]
        }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :action => "edit_class" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :action => "edit_class" and return
      end
    end
    render :layout => false
  end
  def remove_class
    @class_rooms = ClassRoom.all
    render :layout => false
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
    render :layout => false
  end

  def assign_me_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = Course.all
    
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
      redirect_to :action => "assign_me_subjects", :class_room_id => params[:class_room_id] and return
    end
    render :layout => false
  end
  
  def edit_subjects
    @class_rooms = ClassRoom.all
    render :layout => false
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
    render :layout => false
  end
  
  def assign_teacher
    @class_rooms = ClassRoom.all
    render :layout => false
  end

  def assign_me_teachers
    @class_room = ClassRoom.find(params[:class_room_id])
    @teachers = Teacher.all

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
      redirect_to :action => "assign_me_teachers", :class_room_id => params[:class_room_id] and return
    end
    render :layout => false
  end
  
  def edit_teacher
    @class_rooms = ClassRoom.all
    render :layout => false
  end

  def edit_my_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @all_teachers = Teacher.all
    @assigned_teachers = []

    unless (@class_room.class_room_teachers.blank?)
      @assigned_teachers = @class_room.class_room_teachers.collect{|c| c.teacher_id}
      #@assigned_courses = Course.find(:all, :conditions => ["course_id IN (?)", assigned_course_ids] )
    end
    if (request.method == :post)
      ActiveRecord::Base.transaction do
        @class_room.class_room_courses.delete_all

        (params[:teachers] || []).each do |teacher_id, details|
          ClassRoomTeacher.create({
              :class_room_id => params[:class_room_id],
              :teacher_id => teacher_id
            }) #To be continued later
        end
        flash[:notice] = "You have successfuly edited courses"
        redirect_to :action => "edit_my_subjects", :class_room_id => params[:class_room_id] and return
      end
    end
    render :layout => false
  end
  
  def create_class_rooms
    class_name = params[:class_name]
    year = params[:year]
    grade = params[:grade]
    if (ClassRoom.create({
        :year => year,
        :grade => grade,
        :name => class_name
      }))
        flash[:notice] = "You have successfully created classroom"
        redirect_to :action => "add_class" and return
    else
      flash[:error] = "Operation not successful. Check for errors and try again"
      render :action => "add_class" and return
    end
  end
  
end
