class TeacherController < ApplicationController
  def index
    @teachers = Teacher.find(:all, :limit => 5)
    render :layout => false
  end

  def add_teacher
    render :layout => false
  end

  def assign_class
    @teachers = Teacher.all
    render :layout => false
  end

  def assign_me_class
    my_class_room_ids = ClassRoomTeacher.find(:all, :conditions => ["teacher_id =?",
        params[:teacher_id]]).map(&:class_room_id)
    my_class_room_ids = '' if my_class_room_ids.blank?
    @class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id NOT IN (?)", my_class_room_ids])
    render :layout => false
  end

  def assign_me_subjects_menu
    teacher_id = params[:teacher_id]
    @my_class_rooms = ClassRoomTeacher.find(:all, :conditions => ["teacher_id =?",
        teacher_id]).collect{|crt|crt.class_room}
    render :layout => false
  end

  def assign_edit_my_subjects
    teacher_id = params[:teacher_id]
    class_room_id = params[:class_room_id]
    @courses = ClassRoom.find(class_room_id).class_room_courses.collect{|crc|crc.course}
    render :layout => false
  end

  def assign_optional_courses

  end
  
  def teacher_stats
     render :layout => false
  end

  def create_teacher_class_assignment
    teacher_id = params[:teacher_id]
    class_room_id = params[:class_room_id]
    if (ClassRoomTeacher.create({
        :teacher_id => teacher_id,
        :class_room_id => class_room_id
      }))
        flash[:notice] = "You have successfully assigned a class"
        redirect_to :action => "assign_class" and return
      else
        flash[:error] = "Oops!!. Operation aborted"
        redirect_to :action => "assign_me_class", :teacher_id => params[:teacher_id] and return
      end
  end
  
  def assign_subjects
     @teachers = Teacher.all
     render :layout => false
  end

  def filter_teachers
     render :layout => false
  end

  def edit_teacher
    @teachers = Teacher.all
    render :layout => false
  end

  def create
    if Teacher.create(:email => params[:email],
                            :password => params[:password],
                            :fname => params[:first_name],
                            :lname => params[:last_name],
                            :dob => params[:dob].to_date,
                            :gender => params[:gender],
                            :phone => params[:phone],
                            :mobile => params[:mobile],
                            :status => params[:status])
      flash[:notice] = "Teacher successfully added"
    else
       flash[:error] = "Unable to save. Check for errors and try again"
    end
    redirect_to :controller => "teacher", :action => "add_teacher"
  end

  def edit_me
    teacher_id = params[:teacher_id]
    @teacher = Teacher.find(teacher_id)
    
    if request.method == :post
      if (@teacher.update_attributes({
          :fname => params[:first_name],
          :lname => params[:last_name],
          :gender => params[:gender],
          :email => params[:email],
          :phone => params[:phone],
          :dob => params[:dob].to_date
        }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :controller => "teacher", :action => "edit_teacher" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :controller => "teacher", :action => "edit_teacher" and return
      end
    end

    render :layout => false
  end

  def search_teachers
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    conditions = ""
    multiple = false
    unless first_name.blank?
      multiple = true
      conditions += "fname LIKE '%#{first_name}%'"
    end

    unless last_name.blank?
      multiple = true
      conditions += ' AND ' unless conditions.blank?
      conditions += "lname LIKE '%#{last_name}%' "
    end

    unless gender.blank?
      conditions += ' AND ' if multiple
      conditions += "gender = '#{gender}' "
    end

    unless conditions.blank?
      teachers = Teacher.find_by_sql("SELECT * FROM teacher WHERE #{conditions}")
    else
      teachers = Teacher.all
    end

    hash = {}
    
    teachers.each do |teacher|
      teacher_id = teacher.id.to_s
      hash[teacher_id] = {}
      hash[teacher_id]["fname"] = teacher.fname.to_s
      hash[teacher_id]["lname"] = teacher.lname.to_s
      hash[teacher_id]["phone"] = teacher.phone
      hash[teacher_id]["email"] = teacher.email
      hash[teacher_id]["gender"] = teacher.gender
      hash[teacher_id]["dob"] = teacher.dob.to_date.strftime("%d-%b-%Y")
      hash[teacher_id]["join_date"] = teacher.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end
  
end
