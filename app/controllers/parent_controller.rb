class ParentController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all).map(&:name)
    class_rooms = ClassRoom.find(:all)
    hash = {}
    @total_guardians = []
    @students_with_guardians = []
    @students_without_guardians = []
    
    (class_rooms || []).each do |class_room|
      class_room_id = class_room.id
      hash[class_room_id] = {}
      total_guardians = 0
      
      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        next if crs.student.student_parent.blank?
        total_guardians += 1 #Counting available guardians per class
      end

      hash[class_room_id]["total_guardians"] = total_guardians
      with_guardians = 0
      without_guardians = 0

      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        if crs.student.student_parent.blank?
          without_guardians += 1
        end
        unless crs.student.student_parent.blank?
          with_guardians += 1
        end
      end
      
      hash[class_room_id]["with_guardians"] = with_guardians
      hash[class_room_id]["without_guardians"] = without_guardians
    end

    @statistics = hash.sort_by{|key, value|key.to_i}
    
    @statistics.each do |key, value|
      @total_guardians << value["total_guardians"]
      @students_with_guardians << value["with_guardians"]
      @students_without_guardians << value["without_guardians"]
    end
    
    
  end

  def new_parent_guardian
    
  end
  
  def edit_parent_guardian
    @parents = Parent.all
    
  end
  
  def edit_me
    parent_id = params[:parent_id]
    @parent = Parent.find(parent_id)
    if request.method == :post
      password = params[:password]
      password_confirm = params[:password_confirm]
      parent_account = Parent.find_by_username(params[:username])

      errors = ""
      errors += ' Password mismatch.' if (password != password_confirm)

      unless parent_account.blank?
        unless (parent_account.id == @parent.id)
          errors += 'Username already exists.'
        end
      end

      unless (errors.blank?)
        flash[:error] = "#{errors}"
        redirect_to :controller => "parent", :action => "edit_me", :parent_id => params[:parent_id] and return
      end
      
      if (@parent.update_attributes({
              :fname => params[:firstname],
              :lname => params[:lastname],
              :gender => params[:gender],
              :email => params[:email],
              :phone => params[:phone],
              :dob => params[:dob].to_date
            }))
        flash[:notice] = "You have successfully edited the details"
        if params[:return_uri]
          redirect_to :controller => "parent", :action => "my_demographics", :guardian_id => params[:parent_id] and return
        end
        redirect_to :controller => "parent", :action => "edit_parent_guardian" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        if params[:return_uri]
          redirect_to :controller => "parent", :action => "my_demographics", :guardian_id => params[:parent_id] and return
        end
        redirect_to :controller => "parent", :action => "edit_parent_guardian" and return
      end
    end
    
  end

  def void_parent_guardian
    @parents = Parent.all
    
  end

  def delete_parents
    if (params[:mode] == 'single_entry')
      parent = Parent.find(params[:parent_id])
      parent.delete
      render :text => "true" and return
    end

    parent_ids = params[:parent_ids].split(",")
    (parent_ids || []).each do |parent_id|
      parent = Parent.find(parent_id)
      parent.delete
    end
    render :text => "true" and return
  end

  def filter_guardians
    @class_rooms = [["All", "All"]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}
    
    @parents = Parent.find(:all)
    if (request.method == :post)
      class_room_id = params[:class_room]
      gender = params[:gender]
      class_room_conditions = ""
      gender_conditions = ""
      
      if (params[:class_room].to_s.upcase == 'ALL')
        class_room_ids = ClassRoom.all.collect{|c| c.id}.join(', ')
        class_room_conditions = "scra.new_class_room_id IN (#{class_room_ids})"
      else
        class_room_conditions = "scra.new_class_room_id = #{class_room_id}"
      end

      if (params[:gender].to_s.upcase == 'ALL')
        gender_conditions = "p.gender IN ('Male', 'Female')"
      else
        gender_conditions = "p.gender = '#{gender}'"
      end

      parents = StudentParent.find_by_sql("SELECT * FROM student_parent sp INNER JOIN parent p
          ON sp.parent_id=p.parent_id INNER JOIN student_class_room_adjustment scra
          ON sp.student_id=scra.student_id WHERE #{class_room_conditions}
          AND #{gender_conditions} AND scra.status = 'Active'"
      ).collect{|sp|sp.parent}

      hash = {}
      (parents || []).each do |parent|
        parent_id = parent.id.to_s
        hash[parent_id] = {}
        hash[parent_id]["fname"] = parent.fname.to_s
        hash[parent_id]["lname"] = parent.lname.to_s
        hash[parent_id]["phone"] = parent.phone
        hash[parent_id]["email"] = parent.email
        hash[parent_id]["gender"] = parent.gender
        hash[parent_id]["dob"] = parent.dob.to_date.strftime("%d-%b-%Y")
        hash[parent_id]["join_date"] = parent.created_at.to_date.strftime("%d-%b-%Y")
      end

      render :text => hash.to_json and return
    end
    
  end
  
  def create
    first_name = params[:firstname]
    last_name = params[:lastname]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    date_of_birth = params[:dob].to_date

    password = params[:password]
    password_confirm = params[:password_confirm]
    errors = ""
    user_exists = Parent.find_by_username(params[:username])
    errors += 'Username already exists.' if user_exists
    errors += ' Password mismatch.' if (password != password_confirm)

    unless (errors.blank?)
      flash[:error] = "#{errors}"
      redirect_to :controller => "parent", :action => "new_parent_guardian" and return
    end
    
    if (Parent.create({
            :fname => first_name,
            :lname => last_name,
            :password => password,
            :username => params[:username],
            :gender => gender,
            :email => email,
            :phone => phone,
            :dob => date_of_birth
          }))

      if (params[:mode] == 'guardian_edit')
        ActiveRecord::Base.transaction do
          student_parent = StudentParent.find(:last, :conditions => ["student_id =?",
              params[:student_id]])
          student_parent.delete

          StudentParent.create({
              :student_id => params[:student_id],
              :parent_id => Parent.last.id
            })
        end
        flash[:notice] = "Operation successful"
        redirect_to :controller => "student", :action => "select_guardian", :student_id => params[:student_id], :mode => params[:mode] and return
      end

      if (params[:mode].blank?)
        unless params[:student_id].blank?
          if (StudentParent.create({
                  :student_id => params[:student_id],
                  :parent_id => Parent.last.id
                }))
            flash[:notice] = "Operation successful"
            if params[:return_uri]
              redirect_to :controller => "student" ,:action => params[:return_uri], :student_id => params[:student_id] and return
            end
            redirect_to :controller => "payments", :action => "add_student_payment", :student_id => params[:student_id] and return
            #redirect_to :controller => "student" ,:action => "assign_parent_guardian" and return
          else
            flash[:error] = "Unable to save. Check for errors and try again"
            if params[:return_uri]
              redirect_to :controller => "student" ,:action => params[:return_uri], :student_id => params[:student_id] and return
            end
            redirect_to :controller => "parent", :action => "new_parent_guardian", :first_name => params[:first_name],
              :last_name => params[:last_name], :gender => params[:gender] and return
          end
        end
      end

      flash[:notice] = "Operation successful"
      redirect_to :controller => "parent", :action => "new_parent_guardian" and return #creating a parent without a student ID
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "parent", :action => "new_parent_guardian" and return
    end
  end

  def search_parents
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
      parents = Parent.find_by_sql("SELECT * FROM parent WHERE #{conditions}")
    else
      parents = Parent.all
    end

    hash = {}
    parents.each do |parent|
      parent_id = parent.id.to_s
      hash[parent_id] = {}
      hash[parent_id]["fname"] = parent.fname.to_s
      hash[parent_id]["lname"] = parent.lname.to_s
      hash[parent_id]["phone"] = parent.phone
      hash[parent_id]["email"] = parent.email
      hash[parent_id]["gender"] = parent.gender
      hash[parent_id]["dob"] = parent.dob.to_date.strftime("%d-%b-%Y")
      hash[parent_id]["join_date"] = parent.created_at.to_date.strftime("%d-%b-%Y")
      hash[parent_id]["guardian_name"] = parent.name
    end
    render :json => hash and return
  end

  def parents_menu
    @class_rooms = ClassRoom.find(:all).map(&:name)
    class_rooms = ClassRoom.find(:all)
    hash = {}
    @total_guardians = []
    @students_with_guardians = []
    @students_without_guardians = []

    (class_rooms || []).each do |class_room|
      class_room_id = class_room.id
      hash[class_room_id] = {}
      total_guardians = 0

      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        next if crs.student.student_parent.blank?
        total_guardians += 1 #Counting available guardians per class
      end

      hash[class_room_id]["total_guardians"] = total_guardians
      with_guardians = 0
      without_guardians = 0

      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        if crs.student.student_parent.blank?
          without_guardians += 1
        end
        unless crs.student.student_parent.blank?
          with_guardians += 1
        end
      end

      hash[class_room_id]["with_guardians"] = with_guardians
      hash[class_room_id]["without_guardians"] = without_guardians
    end

    @statistics = hash.sort_by{|key, value|key.to_i}

    @statistics.each do |key, value|
      @total_guardians << value["total_guardians"]
      @students_with_guardians << value["with_guardians"]
      @students_without_guardians << value["without_guardians"]
    end

    
  end

  def parent_management_dashboard
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

  def my_page
    @guardian = Parent.find(params[:guardian_id])
  end

  def my_students
    @guardian = Parent.find(params[:guardian_id])
    @students = []
    @guardian.student_parents.each do |student_parent|
      next if student_parent.student.blank?
      @students << student_parent.student
    end
  end

  def my_demographics
    @guardian = Parent.find(params[:guardian_id])
    @parent = @guardian
  end

  def remove_guardian
    @guardian = Parent.find(params[:guardian_id])
    if request.method == :post
      ActiveRecord::Base.transaction do
        @guardian.student_parents.each do |student_parent|
          student_parent.delete
        end
        @guardian.delete
      end
      flash[:notice] = "Operation successful"
      render :text => "true" and return
    end
  end

  def assign_student
    @guardian = Parent.find(params[:guardian_id])
    @students = Student.all
  end

  def create_student_guardian
    student_parent_exists = StudentParent.find(:last, :conditions => ["student_id =? AND
        parent_id =?", params[:student_id], params[:parent_id]])

    if student_parent_exists
      flash[:error] = "The selected student is already assigned to the selected guardian"
      redirect_to :controller => "parent", :action => "my_students", :guardian_id => params[:parent_id] and return
    end

    if (StudentParent.create({
            :student_id => params[:student_id],
            :parent_id => params[:parent_id]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "parent", :action => "my_students", :guardian_id => params[:parent_id] and return
    else
      flash[:error] = "Process aborted. Check for errors and try again"
      redirect_to :controller => "parent", :action => "my_students", :guardian_id => params[:parent_id] and return
    end
  end

  def remove_student_association
    student_parent = StudentParent.find(:last, :conditions => ["student_id =? AND
        parent_id =?", params[:student_id], params[:guardian_id]])
    student_parent.delete
    render :text => "true" and return
  end

  def guardians_page
    @guardian = Parent.last
    render :layout => "guardians"
  end

  def guardians_profile
    @guardian = Parent.last
    render :layout => "guardians"
  end

  def student_performance_summary
    @guardian = Parent.last
    @students = Student.find(:all, :limit => 2)
    render :layout => "guardians"
  end

  def student_payments_summary
    @guardian = Parent.last
    @students = Student.find(:all, :limit => 2)
    render :layout => "guardians"
  end

  def student_punishments_summary
    @guardian = Parent.last
    @students = Student.find(:all, :limit => 2)
    render :layout => "guardians"
  end

  def render_student_payments_summary
    student = Student.find(params[:student_id])
    payment_hash = {}
    semester_hash = {}
    payment_types_hash = {}

    SemesterAudit.all.each do |semester_audit|
      semester_audit_id = semester_audit.semester_audit_id
      semester_hash[semester_audit_id] = semester_audit.semester.semester_number
    end

    PaymentType.all.each do |payment_type|
      payment_type_id = payment_type.payment_type_id
      payment_types_hash[payment_type_id] = payment_type.name
    end

    (student.payments || []).each do |payment|
      semester_audit_id = payment.semester_audit_id
      payment_id = payment.id
      payment_type = payment.payment_type_id
      date_paid = payment.date
      amount_paid = payment.amount_paid
      amount_required = payment.payment_type.amount_required
      payment_hash[semester_audit_id] = {} if payment_hash[semester_audit_id].blank?
      payment_hash[semester_audit_id][payment_type] = {} if payment_hash[semester_audit_id][payment_type].blank?
      payment_hash[semester_audit_id][payment_type][payment_id] = {} if payment_hash[semester_audit_id][payment_type][payment_id].blank?
      payment_hash[semester_audit_id][payment_type][payment_id]["date_paid"] = date_paid
      payment_hash[semester_audit_id][payment_type][payment_id]["amount_paid"] = amount_paid

      amount_paid_to_be_formatted = payment_hash[semester_audit_id][payment_type][payment_id]["amount_paid"]
      payment_hash[semester_audit_id][payment_type][payment_id]["amount_paid_formatted"] = ActionController::Base.helpers.number_to_currency(amount_paid_to_be_formatted, :unit => 'MK')

      payment_hash[semester_audit_id][payment_type]["balance"] = amount_required.to_i if payment_hash[semester_audit_id][payment_type]["balance"].blank?
      payment_hash[semester_audit_id][payment_type]["balance"] -= amount_paid.to_i

      balance = payment_hash[semester_audit_id][payment_type]["balance"]
      payment_hash[semester_audit_id][payment_type]["balance_formatted"] = ActionController::Base.helpers.number_to_currency(balance, :unit => 'MK')

      payment_hash[semester_audit_id][payment_type]["amount_required"] = amount_required.to_i
      amount_required_to_be_formatted = payment_hash[semester_audit_id][payment_type]["amount_required"]
      payment_hash[semester_audit_id][payment_type]["amount_required_formatted"] = ActionController::Base.helpers.number_to_currency(amount_required_to_be_formatted, :unit => 'MK')
      
      payment_hash[semester_audit_id][payment_type]["total_payments"] = 0 if payment_hash[semester_audit_id][payment_type]["total_payments"].blank?
      payment_hash[semester_audit_id][payment_type]["total_payments"] += amount_paid.to_i

      total_payments = payment_hash[semester_audit_id][payment_type]["total_payments"]
      payment_hash[semester_audit_id][payment_type]["total_payments_formatted"] = ActionController::Base.helpers.number_to_currency(total_payments, :unit => 'MK')
    end

    hash = {"semester_hash" => semester_hash, "payment_types_hash" => payment_types_hash, "payment_hash" => payment_hash}
    render :text => hash.to_json and return
  end
  
  def render_student_performance_summary

    student = Student.find(params[:student_id])
    class_room_hash = {}
    class_rooms = ClassRoom.find(:all)
    class_rooms.each do |c|
      class_room_hash[c.id] = c.name
    end

    current_class_room_id = ""
    active_class_adjustment = student.student_class_room_adjustments.find(:last,
      :conditions => ["status =?", 'active'])
    current_class_room_id = active_class_adjustment.new_class_room_id unless active_class_adjustment.blank?

    exams_hash = {}

    (student.exam_attendees || []).each do |exam_attendee|
      next if exam_attendee.examination.blank? #The exam might have been deleted
      exam_id = exam_attendee.examination.id
      class_room_id = exam_attendee.examination.class_room_id
      course_name = exam_attendee.examination.course.name
      exam_type = exam_attendee.examination.examination_type.name
      exam_date = exam_attendee.examination.start_date
      exam_results = ""
      status = "previous"
      if (class_room_id.to_i == current_class_room_id.to_i)
        status = 'current'
      end

      unless (exam_attendee.examination.examination_results.blank?)
        result = ExaminationResult.find(:last, :conditions => ["exam_id =? AND student_id=?",
            exam_attendee.examination.id, student.student_id])
        exam_results = result.marks unless result.blank?
      end

      exams_hash[class_room_id] = {} if exams_hash[class_room_id].blank?
      exams_hash[class_room_id][exam_id] = {} if exams_hash[class_room_id][exam_id].blank?
      exams_hash[class_room_id][exam_id]["exam_type"] = exam_type
      exams_hash[class_room_id][exam_id]["course"] = course_name
      exams_hash[class_room_id][exam_id]["exam_date"] = exam_date
      exams_hash[class_room_id][exam_id]["exam_results"] = exam_results
      exams_hash[class_room_id][exam_id]["status"] = status
    end
    
    hash = {"class_room_hash" => class_room_hash, "exams_hash" => exams_hash}
    
    render :text => hash.to_json and return
  end

  def render_student_punishments_summary
    student = Student.find(params[:student_id])
    punishment_hash = {}

    (student.student_punishments || []).each do |student_punishment|
      punishment_id = student_punishment.punishment.id
      punishment_type = student_punishment.punishment.punishment_type.name
      start_date = student_punishment.punishment.start_date
      end_date = student_punishment.punishment.end_date
      punishment_details = student_punishment.punishment.details
      status = 'No'
      status = 'Yes' if student_punishment.completed.to_i == 1
      punishment_hash[punishment_id] = {}
      punishment_hash[punishment_id]["punishment_type"] = punishment_type
      punishment_hash[punishment_id]["details"] = punishment_details
      punishment_hash[punishment_id]["start_date"] = start_date
      punishment_hash[punishment_id]["end_date"] = end_date
      punishment_hash[punishment_id]["completed"] = status
    end
    
    render :text => punishment_hash.to_json and return
  end

  def student_new_examination_notifications
    @guardian = Parent.last
    guardian_id = 1
    my_students = @guardian.student_parents.collect{|sp|sp.student}.compact
    examination_notifications = GuardianNotification.find(:all, :conditions => ["guardian_id =? AND
      record_type =?", guardian_id, 'new_examination'])
    @notifications_hash = {}

    my_students.each do |student|
      student_id = student.student_id
      @notifications_hash[student_id] = {}
      examination_notifications.each do |notifications|
        exam_id = notifications.record_id
        student_exam_attendance_record = ExamAttendee.find(:last, :conditions => ["exam_id =? AND 
            student_id =?", exam_id, student_id])
        unless student_exam_attendance_record.blank?
          exam = Examination.find(exam_id)
          @notifications_hash[student_id][exam_id] = {}
          @notifications_hash[student_id][exam_id]["exam_type"] = exam.examination_type.name
          @notifications_hash[student_id][exam_id]["course"] = exam.course.name
          @notifications_hash[student_id][exam_id]["exam_date"] = exam.start_date
        end
      end
    end

    render :layout => "guardians"
  end

  def student_new_payment_notifications
    @guardian = Parent.last
    guardian_id = 1
    my_students = @guardian.student_parents.collect{|sp|sp.student}.compact
    payments_notifications = GuardianNotification.find(:all, :conditions => ["guardian_id =? AND
      record_type =?", guardian_id, 'new_payment'])
    @notifications_hash = {}

    my_students.each do |student|
      student_id = student.student_id
      @notifications_hash[student_id] = {}
      payments_notifications.each do |notifications|
        payment_id = notifications.record_id
        student_payment_record = Payment.find(:last, :conditions => ["payment_id =? AND
            student_id =?", payment_id, student_id])
        unless student_payment_record.blank?
          payment = Payment.find(payment_id)
          @notifications_hash[student_id][payment_id] = {}
          @notifications_hash[student_id][payment_id]["payment_type"] = payment.payment_type.name
          @notifications_hash[student_id][payment_id]["amount_paid"] = payment.amount_paid
          @notifications_hash[student_id][payment_id]["date_paid"] = payment.date
        end
      end
    end

    render :layout => "guardians"
  end

  def student_new_exam_results_notifications
    @guardian = Parent.last
    guardian_id = 1
    my_students = @guardian.student_parents.collect{|sp|sp.student}.compact
    exam_results_notifications = GuardianNotification.find(:all, :conditions => ["guardian_id =? AND
      record_type =?", guardian_id, 'new_examination_results'])
    @notifications_hash = {}

    my_students.each do |student|
      student_id = student.student_id
      @notifications_hash[student_id] = {}
      exam_results_notifications.each do |notifications|
        exam_result_id = notifications.record_id
        exam_result_record = ExaminationResult.find(:last, :conditions => ["exam_result_id =? AND
            student_id =?", exam_result_id, student_id])
        unless exam_result_record.blank?
          exam_result = ExaminationResult.find(exam_result_id)
          @notifications_hash[student_id][exam_result_id] = {}
          @notifications_hash[student_id][payment_id]["exam_type"] = exam_result.examination.examination_type.name
          @notifications_hash[student_id][payment_id]["course"] = exam_result.examination.course.name
          @notifications_hash[student_id][payment_id]["exam_date"] = exam_result.examination.start_date
          @notifications_hash[student_id][payment_id]["exam_result"] = exam_result.marks
        end
      end
    end

    render :layout => "guardians"
  end

  def student_new_punishments_notifications
    @guardian = Parent.last
    render :layout => "guardians"
  end

end
