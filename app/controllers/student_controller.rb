class StudentController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all).map(&:name)

    @totals = []
    @males = []
    @females = []

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

  def my_results
    
  end

  def add_student
    
  end

  def edit_student
    @students = Student.all
    
  end

  def remove_students
    @students = Student.all
    
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
    
  end
  
  def assign_me_class
    @class_rooms = ClassRoom.all
    
  end

  def create_student_class_assignment

    student_id = params[:student_id]
    class_room_id = params[:class_room_id]

    class_room_courses = ClassRoom.find(class_room_id).class_room_courses
    (class_room_courses || []).each do |crc|
      next if (crc.course.optional == true) #We don't want to assign optional courses by default
      student_class_room_course = StudentClassRoomCourse.find(:last, :conditions => ["
          student_id =? AND class_room_id =? AND course_id =?", student_id, class_room_id, crc.course_id])
      StudentClassRoomCourse.create({
          :student_id => student_id,
          :class_room_id => class_room_id,
          :course_id => crc.course_id
        }) if student_class_room_course.blank?

    end #Enrolling student to courses available for a particular class

    unless student_id.blank?
      student = Student.find(student_id)
      student_class_adjustment = student.student_class_room_adjustments.last rescue nil
      unless student_class_adjustment.blank?
        student_class_adjustment.update_attributes({
            :status => 'passive'
          })
        student.student_class_room_adjustments.create({
            :old_class_room_id => student_class_adjustment.new_class_room_id,
            :new_class_room_id => class_room_id,
            :status => 'active',
            :semester_id => (GlobalProperty.find_by_property("current_semester").value rescue nil)
          })
      else
        student.student_class_room_adjustments.create({
            :old_class_room_id => 0,
            :new_class_room_id => class_room_id,
            :status => 'active',
            :semester_id => (GlobalProperty.find_by_property("current_semester").value rescue nil)
          })
      end
      flash[:notice] = "You have successfully assigned a class"
      if params[:return_uri]
        redirect_to :controller => "student", :action => params[:return_uri], :student_id => params[:student_id] and return
      end
      redirect_to :controller => "student", :action => "assign_optional_courses", :student_id => params[:student_id] and return
    end
  end
  
  def assign_subjects
    @students = Student.find(:all, :joins => [:class_room_student])
    
  end

  def assign_optional_courses

    student = Student.find(params[:student_id])
    @courses = []
    class_room_courses = student.student_class_room_adjustments.last.class_room.class_room_courses
    class_room_courses.each do |class_room_course|
      @courses << class_room_course.course if (class_room_course.course.optional == true)
    end
    if @courses.blank?#if no optional courses
      flash[:notice] = "We have skipped assigning optional courses bacause no optional course is available for this class"
      redirect_to :controller => "student", :action => "select_guardian", :student_id => params[:student_id]
    end
    @my_class_room_id = student.student_class_room_adjustments.last.class_room.class_room_id
    
    if (request.method == :post)
      current_student_class = student.student_class_room_adjustments.last rescue nil
      
      (params[:subjects] || []).each do |subject_id, details|
        student_class_room_course = StudentClassRoomCourse.find(:last, :conditions => ["
          student_id =? AND class_room_id =? AND course_id =?", params[:student_id],
            current_student_class.new_class_room_id, subject_id])
        StudentClassRoomCourse.create({
            :student_id => params[:student_id],
            :class_room_id => current_student_class.new_class_room_id,
            :course_id => subject_id
          }) if student_class_room_course.blank?
      end
      
      flash[:notice] = "You have successfully assigned courses"
      redirect_to :controller => "student", :action => "select_guardian", :student_id => params[:student_id] and return
      #redirect_to :action => "assign_optional_courses", :student_id => params[:student_id] and return
    end
    
    
  end

  def edit_subjects
    @students = Student.find(:all, :joins => [:student_courses]).uniq
    
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
    
    
  end
  
  def assign_parent_guardian
    students_with_guardians_ids = StudentParent.find(:all).map(&:student_id).join(', ')
    @students = Student.find(:all, :conditions => ["student_id NOT IN (?)", students_with_guardians_ids])
    
  end

  def delete_student_guardian
    my_guardian = StudentParent.find(:last, :conditions => ["student_id =?", params[:student_id]])
    my_guardian.delete
    render :text => "success" and return
  end
  
  def edit_parent_guardian
    @students = Student.find(:all, :joins => [:student_parent])
    
  end
  
  def select_guardian
    student_id = params[:student_id]
    student_parent = StudentParent.find(:last, :conditions => ["student_id =?", student_id])
    @student = Student.find(params[:student_id])
    unless student_parent.blank?
      flash[:error] = "This student already has a guardian registered in the system"
      redirect_to :controller => "payments", :action => "add_student_payment", :student_id => params[:student_id] and return
    end
    
    @parents = Parent.all
    
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
      redirect_to :controller => "payments", :action => "add_student_payment", :student_id => params[:student_id] and return
      #redirect_to :action => "assign_parent_guardian" and return
    else
      flash[:error] = "Operation aborted. Check for errors and try again"
      redirect_to :action => "select_guardian", :student_id => params[:student_id] and return
    end
    
  end
  
  def filter_students
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.find(:all).collect{|c|[c.name, c.id]}
    
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
      hash[student_id]["current_class"] = student.current_class
      hash[student_id]["total_photos"] = student.student_photos.count
    end
    render :json => hash
  end

  def edit_me
    student_id = params[:student_id]
    @student = Student.find(student_id)
    if request.method == :post
      if (@student.update_attributes({
              :fname => params[:firstname],
              :lname => params[:lastname],
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
    
  end
  
  def create
    first_name = params[:firstname]
    last_name = params[:lastname]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    password = params[:password] #To be used later
    date_of_birth = params[:dob].to_date
    username = first_name.first.downcase.to_s + '' + last_name.squish.downcase #To be used later
    student = Student.create({
        :fname => first_name,
        :lname => last_name,
        :gender => gender,
        :email => email,
        :phone => phone,
        :dob => date_of_birth
      })
    if student
      flash[:notice] = "Operation successful"
      redirect_to :controller => "student", :action => "assign_me_class", :student_id => student.student_id
      #redirect_to :controller => "student", :action => "add_student"
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "student", :action => "add_student"
    end
  end

  def registration_menu
    @class_rooms = ClassRoom.find(:all).map(&:name)

    @totals = []
    @males = []
    @females = []

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

  def behavior_management_menu
    
  end

  def examination_results_menu
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}

    @exam_types = [["All", "All"]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}

    first_exam = Examination.first
    @first_exam_class_room = first_exam.class_room_id rescue nil
    @first_exam_type = first_exam.exam_type_id rescue nil
    @first_exam_year = first_exam.start_date.to_date.year rescue nil
    @first_exam_course = first_exam.course_id rescue nil

    @exams_per_month = []
    @exam_without_results = []
    @exam_with_results = []

    (1..12).to_a.each do |month_number|
      course_exams = Examination.find(:all, :conditions => ["class_room_id =? AND exam_type_id =?
          AND course_id =? AND DATE_FORMAT(start_date, '%m') =? AND DATE_FORMAT(start_date, '%Y') =?",
          (first_exam.class_room_id rescue nil), (first_exam.exam_type_id rescue nil),
          (first_exam.course_id rescue nil),
          (month_number rescue nil), (first_exam.start_date.to_date.year rescue nil)])
      without_results = 0
      with_results = 0
      (course_exams || []).each do |course_exam|
        if (course_exam.examination_results.blank?)
          without_results += 1
        end

        unless (course_exam.examination_results.blank?)
          with_results += 1
        end
      end

      total_exams_per_month = course_exams.count
      @exams_per_month << total_exams_per_month
      @exam_without_results << without_results
      @exam_with_results << with_results
    end

    start_year = (Date.today.year - 5)
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    class_rooms = ClassRoom.all
    hash = {}
    class_rooms.each do |class_room|
      class_room_id = class_room.id
      hash[class_room_id] = {}
      class_room.class_room_courses.each do |crc|
        course_id = crc.course_id
        course_name = crc.course.name
        hash[class_room_id][course_id] = course_name
      end
    end

    @class_courses = hash.to_json
    
  end

  def payments_management_menu
    
  end

  def id_cards_menu
    
  end

  def semester_statement_menu
    
  end

  def warning_letters_menu
    
  end

  def student_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def behavior_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def examination_results_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def payments_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def id_cards_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def semester_statement_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def warning_letters_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def take_picture
    @students = Student.find(:all)
    
  end

  def add_student_photo
    @student = Student.find(params[:student_id])
    
  end

  def view_student_pictures
    @students = Student.find(:all)
    
  end

  def view_my_pictures
    @student = Student.find(params[:student_id])
    @students_with_photos = []
    student_photos = StudentPhoto.find(:all, :group => "student_id")

    student_photos.each do |student_photo|
      next if student_photo.student.blank?
      @students_with_photos << student_photo.student
    end
    
  end

  def my_page
    @student = Student.find(params[:student_id])
  end
  
  def my_class
    @student = Student.find(params[:student_id])
    @class_rooms = ClassRoom.all
    
    class_adjustments = @student.student_class_room_adjustments.find(:all, :conditions => ["status =?", 'active'])
    unless class_adjustments.blank?
      class_room_ids = class_adjustments.map(&:new_class_room_id)
      @class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id NOT IN (?)", class_room_ids])
    end
    
    @class_rooms_hash = {}
    @student.student_class_room_adjustments.each do |adjustment|
      adjustment_id = adjustment.id
      @class_rooms_hash[adjustment_id] = {}
      @class_rooms_hash[adjustment_id]["semester"] = adjustment.semester
      @class_rooms_hash[adjustment_id]["class_name"] = adjustment.class_room.name
      @class_rooms_hash[adjustment_id]["start_date"] = adjustment.start_date
      @class_rooms_hash[adjustment_id]["end_date"] = adjustment.end_date
      @class_rooms_hash[adjustment_id]["status"] = adjustment.status.capitalize
    end
  end

  def delete_my_classes
    class_room_adjustment_ids = params[:class_room_adjustment_ids].split(",")
    (class_room_adjustment_ids || []).each do |adjustment_id|
      ActiveRecord::Base.transaction do
        student_adjustment = StudentClassRoomAdjustment.find(adjustment_id)
        
        student_class_room_courses = StudentClassRoomCourse.find(:all, :conditions => ["
          student_id =? AND class_room_id =?", params[:student_id], student_adjustment.new_class_room_id])        
        (student_class_room_courses || []).each do |scrc|
          scrc.delete
        end
      
        student_adjustment.delete
      end
    end
    render :text => "true" and return
  end

  def set_my_active_class
    student = Student.find(params[:student_id])
    class_rooms_hash = {}
    ActiveRecord::Base.transaction do
      student_class_room_adjustment = StudentClassRoomAdjustment.find(params[:class_room_adjustment_id])
      student_class_room_adjustment.status = 'active'
      student_class_room_adjustment.save

      (student.student_class_room_adjustments || []).each do |adjustment|
        next if adjustment.id == student_class_room_adjustment.id
        adjustment.status = 'passive'
        adjustment.save
      end
      
      student.student_class_room_adjustments.each do |adjustment|
        adjustment_id = adjustment.id
        class_rooms_hash[adjustment_id] = {}
        class_rooms_hash[adjustment_id]["semester"] = adjustment.semester
        class_rooms_hash[adjustment_id]["class_name"] = adjustment.class_room.name
        class_rooms_hash[adjustment_id]["start_date"] = adjustment.start_date
        class_rooms_hash[adjustment_id]["end_date"] = adjustment.end_date
        class_rooms_hash[adjustment_id]["status"] = adjustment.status.capitalize
      end
    end

    render :text => class_rooms_hash.to_json and return
  end
  
  def my_courses
    @student = Student.find(params[:student_id])
    @active_courses = []
    @previous_class_course_hash = {}
    @class_room_hash = {}
    class_rooms = ClassRoom.find(:all)
    class_rooms.each do |c|
      @class_room_hash[c.id] = c.name
    end
    @current_active_class = ""
    active_class_adjustment = @student.student_class_room_adjustments.find(:last,
      :conditions => ["status =?", 'active'])
    unless active_class_adjustment.blank?
      @current_active_class = active_class_adjustment.class_room.name
      active_class_room_courses = @student.student_class_room_courses.find(:all,
        :conditions => ["class_room_id =?", active_class_adjustment.new_class_room_id])
      active_class_room_courses.each do |active_class_room_course|
        next if active_class_room_course.course.blank?
        @active_courses << active_class_room_course.course
      end
    end

    (@student.student_class_room_adjustments || []).each do |sca|
      unless active_class_adjustment.blank?
        next if sca.id == active_class_adjustment.id
      end
      class_room_id = sca.new_class_room_id
      @previous_class_course_hash[class_room_id] = {}
      @previous_class_course_hash[class_room_id]["courses"] = []
      previous_class_room_courses = @student.student_class_room_courses.find(:all,
        :conditions => ["class_room_id =?",class_room_id])
      previous_class_room_courses.each do |previous_class_room_course|
        course = previous_class_room_course.course
        @previous_class_course_hash[class_room_id]["courses"] << course
      end
    end
  end

  def my_performance
    @student = Student.find(params[:student_id])
  end

  def my_department
    @student = Student.find(params[:student_id])
  end

  def my_punishments
    @student = Student.find(params[:student_id])
  end

  def my_payments
    @student = Student.find(params[:student_id])
  end

  def my_guardian
    @student = Student.find(params[:student_id])
  end

  def my_photos
    @student = Student.find(params[:student_id])
  end
end
