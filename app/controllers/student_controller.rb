class StudentController < ApplicationController
  def index
=begin
    class_rooms = ClassRoom.find(:all)
    hash = {}

    (class_rooms || []).each do |class_room|
      total_students = class_room.class_room_students.count
      class_room_id = class_room.id
      hash[class_room_id] = {}
      hash[class_room_id]["total_students"] = total_students
      total_males = 0
      total_females = 0

      class_room.class_room_students.each do |crs|
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
    
    @statistics = hash
=end
    render :layout => false
  end

  def my_results
    render :layout => false
  end

  def add_student
    render :layout => false
  end

  def edit_student
    @students = Student.all
    render :layout => false
  end

  def remove_students
    @students = Student.all
    render :layout => false
  end

  def delete_students
    if (params[:mode] == 'single_entry')
      student = Student.find(params[:student_id])
      student.delete
      render :text => "true" and return
    end

    student_ids = params[:student_ids].split(",")
    (student_ids || []).each do |student_id|
        student = Student.find(student_id)
        student.delete
    end
    
    render :text => "true" and return
  end
  
  def assign_class
     student_ids_with_class_rooms = Student.find(:all,
          :joins => [:class_room_student]).map(&:student_id)

    student_ids_with_class_rooms = '' if student_ids_with_class_rooms.blank? #To handle mysql NOT IN when the data is array is blank
     @students = Student.find(:all, :conditions => ["student_id NOT IN (?)",
                    student_ids_with_class_rooms]
                )
    render :layout => false
  end
  
  def assign_me_class
    @class_rooms = ClassRoom.all
    render :layout => false
  end

  def create_student_class_assignment

    student_id = params[:student_id]
    class_room_id = params[:class_room_id]

    class_room_courses = ClassRoom.find(class_room_id).class_room_courses
    (class_room_courses || []).each do |crc|
      StudentCourse.create({
        :student_id => student_id,
        :course_id => crc.course_id
      })
    end #Enrolling student to courses available for a particular class

    unless student_id.blank?
      if (ClassRoomStudent.create({
        :student_id => student_id,
        :class_room_id => class_room_id
      }))
        flash[:notice] = "You have successfully assigned a class"
        redirect_to :action => "assign_class"
      else
        flash[:error] = "Oops!!. Operation aborted"
        redirect_to :action => "assign_me_class", :student_id => params[:student_id]
      end
    end
  end
  
  def assign_subjects
    @students = Student.find(:all, :joins => [:class_room_student])
    render :layout => false
  end

  def assign_optional_courses
    student = Student.find(params[:student_id])
    @courses = student.class_room_student.class_room.class_room_courses.collect{|crc|
      crc.course
    }
    
    if (request.method == :post)
      (params[:subjects] || []).each do |subject_id, details|
          StudentCourse.create({
            :student_id => params[:student_id],
            :course_id => subject_id
          })
      end
      flash[:notice] = "You have successfully assigned courses"
      redirect_to :action => "assign_optional_courses" and return
    end
    
    render :layout => false
  end

  def edit_subjects
    @students = Student.find(:all, :joins => [:student_courses])
    render :layout => false
  end

  def edit_my_subjects
    student = Student.find(params[:student_id])
    @current_student_courses = student.student_courses.collect{|sc|sc.course}
    @courses = student.class_room_student.class_room.class_room_courses.collect{|crc|
      crc.course
    }

    if (request.method == :post)
      ActiveRecord::Base.transaction do
        #@class_room.class_room_courses.delete_all
        assigned_course_ids = @current_student_courses.map(&:course_id)
        already_signed_course_ids = []

        (params[:subjects] || []).each do |subject_id, details|
          if (assigned_course_ids.include?(subject_id.to_i))
            already_signed_course_ids << subject_id.to_i
            next
          end
          StudentCourse.create({
              :student_id => params[:student_id],
              :course_id => subject_id
          })
        end

        ((assigned_course_ids - already_signed_course_ids) || []).each do |course_id|
          student_course = StudentCourse.find(:last, :conditions => ["student_id =? AND course_id =?",
              params[:student_id], course_id])
          student_course.delete
        end

        flash[:notice] = "You have successfuly edited subjects"
        redirect_to :action => "edit_subjects" and return
      end
    end
    
    render :layout => false
  end
  
  def assign_parent_guardian
    students_with_guardians_ids = StudentParent.find(:all).map(&:student_id).join(', ')
    @students = Student.find(:all, :conditions => ["student_id NOT IN (?)", students_with_guardians_ids])
    render :layout => false
  end

  def delete_student_guardian
    my_guardian = StudentParent.find(:last, :conditions => ["student_id =?", params[:student_id]])
    my_guardian.delete
    render :text => "success" and return
  end
  
  def edit_parent_guardian
    @students = Student.find(:all, :joins => [:student_parent])
    render :layout => false
  end
  
  def select_guardian
    @parents = Parent.all
    render :layout => false
  end

  def create_student_guardian
    if (params[:mode] == 'guardian_edit')
      ActiveRecord::Base.transaction do
        student_parent = StudentParent.find(:last, :conditions => ["student_id =?",
            params[:student_id]])
        student_parent.delete
        
        StudentParent.create({
          :student_id => params[:student_id],
          :parent_id => params[:parent_id]
        })
      end
      flash[:notice] = "Operation successful"
      redirect_to :action => "select_guardian", :student_id => params[:student_id], :mode => params[:mode] and return
    end

    if (StudentParent.create({
        :student_id => params[:student_id],
        :parent_id => params[:parent_id]
      }))
      flash[:notice] = "Operation successful"
      redirect_to :action => "assign_parent_guardian" and return
    else
      flash[:error] = "Operation aborted. Check for errors and try again"
      redirect_to :action => "select_guardian", :student_id => params[:student_id] and return
    end
    
  end
  
  def filter_students
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.find(:all).collect{|c|[c.name, c.id]}
    render :layout => false
  end

  def filter_students_by_params
    class_room_id = ClassRoom.all.map(&:id)
    gender = params[:gender]
    gender = ["Male", "Female"]
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    date_category = params[:date_category]

    if (date_category == 'today')
      start_date = Date.today
      end_date = Date.today
    end

    if (date_category == 'this_week')
      start_date = Date.today.beginning_of_week #Monday
      end_date = Date.today
    end
    
    if (date_category == 'last_month')
      start_date = Date.today.last_month.beginning_of_month
      end_date = Date.today.last_month.end_of_month
    end

    if (date_category == 'this_year')
      start_date = Date.today.beginning_of_year
      end_date = Date.today
    end

    if (date_category == 'all_dates')
      date_of_join_start = Student.find_by_sql("SELECT date_of_join FROM student ORDER BY DATE(date_of_join) ASC LIMIT 1").last.date_of_join
      date_of_join_end = Student.find_by_sql("SELECT date_of_join FROM student ORDER BY DATE(date_of_join) DESC LIMIT 1").last.date_of_join
      start_date = date_of_join_start.to_date rescue nil
      end_date = date_of_join_end.to_date rescue nil
    end

    unless params[:class_room_id].blank?
      class_room_id = [params[:class_room_id]]
    end
    
    unless  params[:gender].blank?
     gender =  [params[:gender]]
    end

    unless (start_date.blank? && end_date.blank?)
      students = ClassRoomStudent.find(:all, :joins => [:student],
                  :conditions => ["class_room_id IN (?) AND gender IN (?) AND
                   DATE(date_of_join) >= ? AND DATE(date_of_join) <= ?",
                   class_room_id, gender, start_date, end_date]
                 ).collect{|cr| cr.student }
    else
      students = ClassRoomStudent.find(:all, :joins => [:student],
      :conditions => ["class_room_id IN (?) AND gender IN (?)", class_room_id, gender]
        ).collect{|cr| cr.student}
    end
    

    hash = {}
    students.each do |student|
      student_id = student.id.to_s
      hash[student_id] = {}
      hash[student_id]["fname"] = student.fname.to_s
      hash[student_id]["lname"] = student.lname.to_s
      hash[student_id]["phone"] = student.phone
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["dob"] = student.dob.to_date.strftime("%d-%b-%Y")
      hash[student_id]["join_date"] = student.created_at.to_date.strftime("%d-%b-%Y")
    end
    
    render :json => hash
  end
  
  def search_students
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
      students = Student.find_by_sql("SELECT * FROM student WHERE #{conditions}")
    else
      students = Student.all
    end
    
    hash = {}
    students.each do |student|
      student_id = student.id.to_s
      hash[student_id] = {}
      hash[student_id]["fname"] = student.fname.to_s
      hash[student_id]["lname"] = student.lname.to_s
      hash[student_id]["phone"] = student.phone
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["dob"] = student.dob.to_date.strftime("%d-%b-%Y")
      hash[student_id]["join_date"] = student.created_at.to_date.strftime("%d-%b-%Y")
    end
    render :json => hash
  end

  def edit_me
    student_id = params[:student_id]
    @student = Student.find(student_id)
    if request.method == :post
      if (@student.update_attributes({
          :fname => params[:first_name],
          :lname => params[:last_name],
          :gender => params[:gender],
          :email => params[:email],
          :phone => params[:phone],
          :dob => params[:dob].to_date
        }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :controller => "student", :action => "edit_student" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :controller => "student", :action => "edit_student" and return
      end
    end
    render :layout => false
  end
  
  def create
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    password = params[:password] #To be used later
    date_of_birth = params[:dob].to_date
    username = first_name.first.downcase.to_s + '' + last_name.squish.downcase #To be used later
    if (Student.create({
        :fname => first_name,
        :lname => last_name,
        :gender => gender,
        :email => email,
        :phone => phone,
        :dob => date_of_birth
      }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "student", :action => "add_student"
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "student", :action => "add_student"
    end
  end
end
