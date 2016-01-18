class TeacherController < ApplicationController
  def index
    @male_teachers = Teacher.teachers_by_gender('male')
    @female_teachers = Teacher.teachers_by_gender('female')
    @total_teachers = @male_teachers.count + @female_teachers.count
  end

  def add_teacher
    
  end

  def assign_class
    @teachers = Teacher.available_teachers
    
  end

  def remove_class
    @teachers = Teacher.available_teachers
    
  end

  def remove_my_classes
    teacher_id = params[:teacher_id]
    teacher = Teacher.find(teacher_id)
    @my_class_rooms = []

    teacher.class_room_teachers.each do |crt|
      next if crt.class_room.blank?
      @my_class_rooms << crt.class_room
    end
    
    if (request.method == :post)
      if (params[:mode] == 'single_entry')
        class_room_teacher = ClassRoomTeacher.find(:last, :conditions => ["teacher_id =? AND
            class_room_id =?", params[:teacher_id], params[:class_room_id]])

        ActiveRecord::Base.transaction do
          teacher_class_room_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", params[:teacher_id], params[:class_room_id]])
          
          (teacher_class_room_courses || []).each do |tcrc|
            tcrc.delete #Deleting courses associated with this teacher for a particular class
          end

          class_room_teacher.delete
        end
        
        render :text => "true" and return
      end

      class_room_ids = params[:class_room_ids].split(",")
      
      (class_room_ids || []).each do |class_room_id|
        class_room_teacher = ClassRoomTeacher.find(:last, :conditions => ["teacher_id =? AND
            class_room_id =?", params[:teacher_id], class_room_id])

        teacher_class_room_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", params[:teacher_id], class_room_id])

        (teacher_class_room_courses || []).each do |tcrc|
          tcrc.delete #Deleting courses associated with this teacher for a particular class
        end
        
        class_room_teacher.delete
      end

      render :text => "true" and return
    end

    
  end
  
  def assign_me_class
    my_class_room_ids = ClassRoomTeacher.find(:all, :conditions => ["teacher_id =?",
        params[:teacher_id]]).map(&:class_room_id)
    my_class_room_ids = '' if my_class_room_ids.blank?
    @class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id NOT IN (?)", my_class_room_ids])
    
  end

  def assign_me_subjects_menu
    teacher_id = params[:teacher_id]
    teacher = Teacher.find(teacher_id)
    @my_class_rooms = []

    teacher.class_room_teachers.each do |crt|
      next if crt.class_room.blank?
      @my_class_rooms << crt.class_room
    end
    
  end

  def assign_edit_my_subjects
    teacher_id = params[:teacher_id]
    class_room_id = params[:class_room_id]

    @current_teacher_class_room_courses = TeacherClassRoomCourse.find(:all,
      :conditions => ["teacher_id =? AND class_room_id =?",teacher_id, class_room_id]
    ).collect{|i|i.course }
      
    @courses = ClassRoom.find(class_room_id).class_room_courses.collect{|crc|crc.course}
    
  end

  def assign_optional_courses
    teacher_id = params[:teacher_id]
    class_room_id = params[:class_room_id]
    ActiveRecord::Base.transaction do
      current_teacher_class_room_courses = TeacherClassRoomCourse.find(:all,
        :conditions => ["teacher_id =? AND class_room_id =?",teacher_id, class_room_id])

      (current_teacher_class_room_courses || []).each do |ctcrc|
        ctcrc.delete
      end
      
      (params[:subjects] || []).each do |subject_id, details|
        TeacherClassRoomCourse.create({
            :teacher_id => teacher_id,
            :class_room_id => class_room_id,
            :course_id => subject_id
          })
      end
    end
    flash[:notice] = "Operation successful"
    if params[:return_uri]
      redirect_to :controller => "teacher", :action => params[:return_uri], :teacher_id => params[:teacher_id] and return
    end
    redirect_to :action => "assign_subjects" and return
  end
  
  def teacher_stats
    
  end

  def create_teacher_class_assignment
    teacher_id = params[:teacher_id]
    class_room_id = params[:class_room_id]
    if (ClassRoomTeacher.create({
            :teacher_id => teacher_id,
            :class_room_id => class_room_id
          }))
      flash[:notice] = "You have successfully assigned a class"
      if params[:return_uri]
        redirect_to :controller => "teacher", :action => params[:return_uri], :teacher_id => params[:teacher_id] and return
      end
      redirect_to :action => "assign_class" and return
    else
      flash[:error] = "Oops!!. Operation aborted"
      redirect_to :action => "assign_me_class", :teacher_id => params[:teacher_id] and return
    end
  end
  
  def assign_subjects
    @teachers = Teacher.available_teachers
  end

  def filter_teachers
    @class_rooms = [["All", "All"]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}

    @courses = [["All", "All"]]
    @courses += Course.all.collect{|c|[c.name, c.id]}
    @teachers =Teacher.available_teachers
    if (request.method == :post)
      class_room_ids = params[:class_room]
      if (params[:class_room].to_s.upcase == 'ALL')
        class_room_ids = ClassRoom.all.map(&:id).join(', ')
      end
      
      course_ids = params[:course]
      if (params[:course].to_s.upcase == 'ALL')
        course_ids = Course.all.map(&:id).join(', ')
      end
      
      gender = params[:gender]
      gender_conditions = ""
      if (gender.to_s.upcase == 'ALL')
        gender_conditions = "e.gender IN ('Male', 'Female')"
      else
        gender_conditions = "e.gender = '#{gender}'"
      end
      
      teachers = []

      if (params[:course].to_s.upcase == 'ALL')
        teachers = Teacher.class_room_teachers_by_gender(class_room_ids, gender_conditions)
      else
        teachers = Teacher.class_room_teachers_by_gender_and_course_ids(class_room_ids, gender_conditions, course_ids)
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

      render :text => hash.to_json and return
    end
    
    
  end

  def edit_teacher
    @teachers = Teacher.available_teachers
  end

  def create
    teacher_position_id = Position.find_by_name("Teacher").position_id
    ActiveRecord::Base.transaction do
      employee = Employee.create({
          :email => params[:email],
          :fname => params[:firstname],
          :lname => params[:lastname],
          :dob => params[:dob].to_date,
          :gender => params[:gender],
          :phone => params[:phone],
          :mobile => params[:mobile]
        }
      )

      EmployeePosition.create({
          :employee_id => employee.employee_id,
          :position_id => teacher_position_id
        })
    end

    flash[:notice] = "Teacher successfully added"
    redirect_to :controller => "teacher", :action => "add_teacher"
  end

  def edit_me
    teacher_id = params[:teacher_id]
    @teacher = Employee.find(teacher_id)
    
    if request.method == :post
      if (@teacher.update_attributes({
              :fname => params[:firstname],
              :lname => params[:lastname],
              :gender => params[:gender],
              :email => params[:email],
              :phone => params[:phone],
              :dob => params[:dob].to_date
            }))
        flash[:notice] = "You have successfully edited the details"
        if params[:return_uri]
          redirect_to :controller => "teacher", :action => params[:return_uri], :teacher_id => params[:teacher_id] and return
        end
        redirect_to :controller => "teacher", :action => "edit_teacher" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :controller => "teacher", :action => "edit_teacher" and return
      end
    end

    
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

  def manage_teachers_menu
    @male_teachers = Teacher.teachers_by_gender('male')
    @female_teachers = Teacher.teachers_by_gender('female')
    @total_teachers = @male_teachers.count + @female_teachers.count
  end

  def manage_teachers_dashboard
    @class_rooms = ClassRoom.find(:all).map(&:name)

    @totals = []
    @males = []
    @females = []

    class_rooms = ClassRoom.find(:all)
    hash = {}

    (class_rooms || []).each do |class_room|
      class_room_id = class_room.class_room_id
      class_room_teachers = Teacher.class_room_teachers(class_room_id)
      hash[class_room_id] = {}
      hash[class_room_id]["total_teachers"] = class_room_teachers.count
      total_males = 0
      total_females = 0

      class_room_teachers.each do |crt|
        if (crt.gender.to_s.upcase == 'MALE')
          total_males += 1
        end
        if (crt.gender.to_s.upcase == 'FEMALE')
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
      @totals << value["total_teachers"]
    end
    
  end

  def select_from_employees
    @employees = Teacher.non_teachers_employees
    @teachers = Teacher.available_teachers
  end

  def set_employee_as_teacher
    if (params[:mode] == 'single_entry')
      employee = Employee.find(params[:employee_id])
      teacher = Teacher.create({
          :fname => employee.fname,
          :lname => employee.lname,
          :email => employee.email,
          :gender => employee.gender,
          :dob => employee.dob
        })
      EmployeeTeacher.create({
          :employee_id => params[:employee_id],
          :teacher_id => teacher.id
        })
      render :text => "true" and return
    end

    employee_ids = params[:employee_ids].split(",")

    (employee_ids || []).each do |employee_id|
      employee = Employee.find(employee_id)
      teacher = Teacher.create({
          :fname => employee.fname,
          :lname => employee.lname,
          :email => employee.email,
          :gender => employee.gender,
          :dob => employee.dob
        })
      EmployeeTeacher.create({
          :employee_id => employee_id,
          :teacher_id => teacher.id
        })
    end

    render :text => "true" and return
  end

  def my_page
    @teacher = Teacher.find(params[:teacher_id])
  end

  def my_class
    @teacher = Teacher.find(params[:teacher_id])
    @my_class_rooms = []
    @teacher.class_room_teachers.each do |class_room_teacher|
      next if class_room_teacher.class_room.blank?
      @my_class_rooms << class_room_teacher.class_room
    end
  end

  def delete_my_class
    ActiveRecord::Base.transaction do
      teacher = Teacher.find(params[:teacher_id])

      teacher_class_room_courses = teacher.teacher_class_room_courses.find(:all ,
        :conditions => ["class_room_id =?", params[:class_room_id]])
      teacher_class_room_courses.each do |tcrc|
        tcrc.delete
      end
      
      my_class = teacher.class_room_teachers.find(:last, :conditions => ["class_room_id =?",
          params[:class_room_id]])
      my_class.delete
    end
    render :text => "true" and return
  end

  def my_courses
    @teacher = Teacher.find(params[:teacher_id])
    @class_room_hash = {}
    class_rooms = ClassRoom.find(:all)
    class_rooms.each do |c|
      @class_room_hash[c.id] = c.name
    end
    @class_room_courses_hash = {}
    class_room_teachers = @teacher.class_room_teachers

    class_room_teachers.each do |class_room_teacher|
      next if class_room_teacher.class_room.blank?
      class_room_id = class_room_teacher.class_room_id
      teacher_class_room_courses = @teacher.teacher_class_room_courses.find(:all,
        :conditions => ["class_room_id =?", class_room_id])

      @class_room_courses_hash[class_room_id]= {} if @class_room_courses_hash[class_room_id].blank?
      @class_room_courses_hash[class_room_id]["courses"] = [] if @class_room_courses_hash[class_room_id]["courses"].blank?
      teacher_class_room_courses.each do |tcrc|
        course_id = tcrc.course_id
        course = Course.find(course_id)
        @class_room_courses_hash[class_room_id]["courses"] << course
      end      
    end

  end

  def assign_teacher_classes
    @teacher = Teacher.find(params[:teacher_id])
    my_class_room_ids = ClassRoomTeacher.find(:all, :conditions => ["teacher_id =?",
        params[:teacher_id]]).map(&:class_room_id)
    my_class_room_ids = '' if my_class_room_ids.blank?
    @class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id NOT IN (?)", my_class_room_ids])
  end

  def assign_teacher_courses
    class_room_id = params[:class_room_id]
    @teacher = Teacher.find(params[:teacher_id])
    current_class_course_ids = @teacher.teacher_class_room_courses.find(:all,
      :conditions => ["class_room_id =?", class_room_id]).map(&:course_id)
    current_class_course_ids = '' if current_class_course_ids.blank?
    @courses = ClassRoom.find(class_room_id).class_room_courses.find(:all,
      :conditions => ["course_id NOT IN (?)", current_class_course_ids]).collect{|crc|crc.course}
  end

  def delete_my_class_courses
    class_room_id = params[:class_room_id]
    course_id = params[:course_id]
    teacher = Teacher.find(params[:teacher_id])
    teacher_class_room_course = teacher.teacher_class_room_courses.find(:last,
      :conditions => ["class_room_id =? AND course_id =?", class_room_id, course_id])
    teacher_class_room_course.delete
    render :text => "true" and return
  end

  def my_demographics
    @teacher = Teacher.find(params[:teacher_id])
  end

  def remove_teacher
    @teacher = Teacher.find(params[:teacher_id])
    if request.method == :post
      ActiveRecord::Base.transaction do
        @teacher.class_room_teachers.each do |class_room_teacher|
          class_room_teacher.delete
        end
        @teacher.teacher_class_room_courses.each do |teacher_class_room_course|
          teacher_class_room_course.delete
        end
        @teacher.delete
      end
      flash[:notice] = "Operation successful"
      render :text => "true" and return
    end
  end
end
