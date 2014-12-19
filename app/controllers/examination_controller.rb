class ExaminationController < ApplicationController
  def index
    render :layout => false
  end

  def new_exam_type
    if (request.method == :post)
        if (ExaminationType.create({
          :name => params[:exam_type]
        }))
          flash[:notice] = "You have successfully added exam type"
          redirect_to :action => "new_exam_type" and return
        end
    end

    render :layout => false
  end

  def edit_exam_type
    @exam_types = ExaminationType.all
    render :layout => false
  end

  def edit_me
    @exam_type = ExaminationType.find(params[:exam_type_id])
    
    if (request.method == :post)
        if (@exam_type.update_attributes({
          :name => params[:exam_type]
        }))

          flash[:notice] = "You have successfully edited exam type"
          redirect_to :action => "edit_exam_type" and return
        else
          flash[:error] = "Operation aborted"
          redirect_to :action => "edit_me", :exam_type_id => params[:exam_type_id]
        end
    end

    render :layout => false
  end
  
  def void_exam_type
    @exam_types = ExaminationType.all
    render :layout => false
  end
  
  def assign_exam
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}
    
    @courses = [["---Select Course---", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}
    render :layout => false
  end

  def create_exam_assignment
    class_room_id = params[:class_room] #Add class_room_id field in an exam table
    exam_type = params[:exam_type]
    course_id = params[:course]
    exam_date = params[:exam_date]
    ActiveRecord::Base.transaction do
      exam = Examination.new
      exam.class_room_id = class_room_id
      exam.exam_type_id = exam_type
      exam.course_id = course_id
      exam.start_date = exam_date.to_date
      exam.save!
      
      (params[:students] || []).each do |student_id, details|
        exam_attendee = ExamAttendee.new
        exam_attendee.exam_id = exam.id
        exam_attendee.student_id = student_id
        exam_attendee.save!
      end

    end
    flash[:notice] = "Operation successful"
    redirect_to :controller => "examination", :action => "assign_exam"
  end
  
  def edit_exam_assignment
    @exams = Examination.all
    render :layout => false
  end

  def void_exam
    @exams = Examination.all
    render :layout => false
  end

  def delete_exams
    if (params[:mode] == 'single_entry')
      exam = Examination.find(params[:exam_id])
      exam.delete
      render :text => "true" and return
    end

    exam_ids = params[:exam_ids].split(",")
    (exam_ids || []).each do |exam_id|
        exam_id = Examination.find(exam_id)
        exam_id.delete
    end

    render :text => "true" and return
  end
  
  def delete_exam_types
    if (params[:mode] == 'single_entry')
      exam_type = ExaminationType.find(params[:exam_type_id])
      exam_type.delete
      render :text => "true" and return
    end

    exam_type_ids = params[:exam_type_ids].split(",")
      (exam_type_ids || []).each do |exam_type_id|
       exam_type = ExaminationType.find(exam_type_id)
       exam_type.delete
    end
    
    render :text => "true" and return
  end

  def class_room_students
    class_room = ClassRoom.find(params[:class_room_id])
    students = class_room.class_room_students.collect{|crs|crs.student}.compact

    students = (students || []).collect{|s|[s.id, s.fname + ' ' + s.lname]}.in_groups_of(3)
    render :json => students and return
  end

  def class_room_courses
    class_room = ClassRoom.find(params[:class_room_id])
    options = [["", "---Select Course---"]]
    courses = class_room.class_room_courses.collect{|crc| crc.course}.compact
    options += (courses || []).collect{|c|[c.id, c.name]}
    render :json => options and return
  end

  def render_students
    exam_id = params[:exam_id]
    exam_attendees = Examination.find(exam_id).students
    class_name = Examination.find(exam_id).class_room.name
    student_data = {}
    
    (exam_attendees || []).each do |et|
      student_name = (et.fname.to_s + ' ' + et.lname.to_s)
      gender = et.gender.first.capitalize.to_s
      gender = '??' if gender.blank?
      student_data[class_name] = [] if student_data[class_name].blank?
      student_data[class_name] << student_name + ' (' + gender + ')'.to_s
    end

    render :json => student_data.first and return
  end
  
end
