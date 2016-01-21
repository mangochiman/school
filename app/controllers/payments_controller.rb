class PaymentsController < ApplicationController

  def payments_management_menu
    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.status = 'active' AND sa.student_id IS NULL")

    student_ids = students.map(&:student_id).join(', ')
    student_ids = '0' if student_ids.blank?

    @latest_students_payments = Payment.find_by_sql("SELECT p.* FROM payment p WHERE p.student_id IN (#{student_ids})
      ORDER BY DATE(p.date) DESC")
  end

  def payments_management_dashboard
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

  def add_payment
    @students = Student.find(:all)
    
  end
  
  def edit_payment
    @students = Student.find(:all)
    
  end

  def edit_my_payments_menu
    student_id = params[:student_id]
    @student = Student.find(student_id)
    @payments_hash = {}
    @payment_types_hash = {}
    
    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end
    
    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
    end
    
    
  end

  def edit_particular_payment
    payment_id = params[:payment_id]
    @payment = Payment.find(payment_id)
    @student = Student.find(@payment.student_id)
    previous_payments = @student.payments
    @payments_hash = {}
    @payment_types_hash = {}
    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end
    
    previous_payments.each do |payment|
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      latest_payment = @student.payments.find(:first, :order => "DATE(date) DESC",
        :conditions => ["payment_type_id =?", payment_type_id]) if @payments_hash[payment_type_id].blank?

      @payments_hash[payment_type_id]["amount_required"] = payment.payment_type.amount_required.to_i
      @payments_hash[payment_type_id]["amount_paid"] = 0 if @payments_hash[payment_type_id]["amount_paid"].blank?
      @payments_hash[payment_type_id]["amount_paid"] += payment.amount_paid.to_i
      @payments_hash[payment_type_id]["balance"] = payment.payment_type.amount_required.to_i if @payments_hash[payment_type_id]["balance"].blank?
      @payments_hash[payment_type_id]["balance"] -= payment.amount_paid.to_i
      @payments_hash[payment_type_id]["latest_date_paid"] = latest_payment.date.to_date.strftime("%d-%b-%Y") if latest_payment
    end
    
    if request.method == :post
      amount_paid = params[:amount]
      date_paid = params[:payment_date]
      if (@payment.update_attributes({:amount_paid => amount_paid, :date => date_paid}))
        flash[:notice] = "Operation successful"
        redirect_to :controller => "payments", :action => "edit_my_payments_menu", :student_id => @student.student_id and return
      else
        flash[:error] = "Unable to save the details. Check for the errors and try again"
        render :controller => "payments", :action => "edit_my_payments_menu", :student_id => @student.student_id and return
      end
    end
    
    
  end
  
  def void_payments
    @students = Student.find(:all)
    
  end

  def void_my_payments_menu
    student_id = params[:student_id]
    @student = Student.find(student_id)
    @payments_hash = {}
    @payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
    end

    
  end

  def delete_payments
    if (params[:mode] == 'single_entry')
      payment = Payment.find(params[:payment_id])
      payment.delete
      render :text => "true" and return
    end
  end
  
  def view_payments
    @students = Student.find(:all)
    
  end

  def view_my_payments
    student_id = params[:student_id]
    @student = Student.find(student_id)
    @payments_hash = {}
    @payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
      @payments_hash[payment_type_id][payment_id]["date_created"] = payment.created_at.to_date.strftime("%d-%b-%Y")
    end
    
    
  end
  
  def add_student_payment
    @student = Student.find(params[:student_id])

    @payment_types = [["[Payment Type]", ""]]
    @payment_types += PaymentType.all.collect{|c|[c.name, c.id]}
    
    @semesters = [["[Semester]", ""]]
    @semesters += Semester.all.collect{|s|[s.semester_number, s.id]}
    
    @current_student_payments = Payment.find(:all, :conditions => ["student_id =?",
        params[:student_id]])
    @current_semester_id = Semester.current_active_semester_audit.semester_id rescue ''

    @payment_types_hash = {}
    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end
    
    previous_payments = @student.payments

    @payments_hash = {}
    
    previous_payments.each do |payment|
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      latest_payment = @student.payments.find(:first, :order => "DATE(date) DESC",
        :conditions => ["payment_type_id =?", payment_type_id]) if @payments_hash[payment_type_id].blank?
      
      @payments_hash[payment_type_id]["amount_required"] = payment.payment_type.amount_required.to_i
      @payments_hash[payment_type_id]["amount_paid"] = 0 if @payments_hash[payment_type_id]["amount_paid"].blank?
      @payments_hash[payment_type_id]["amount_paid"] += payment.amount_paid.to_i
      @payments_hash[payment_type_id]["balance"] = payment.payment_type.amount_required.to_i if @payments_hash[payment_type_id]["balance"].blank?
      @payments_hash[payment_type_id]["balance"] -= payment.amount_paid.to_i
      @payments_hash[payment_type_id]["latest_date_paid"] = latest_payment.date.to_date.strftime("%d-%b-%Y") if latest_payment
    end
    
    
  end

  def create_student_payment
    #TODO: pull all semester_audits. Back payments are allowed
    student_id = params[:student_id]
    payment_type = params[:payment_type]
    semester_audit_id = params[:semester]
    amount_paid = params[:amount]
    date_paid = params[:payment_date]

    if (Payment.new_payment(student_id, payment_type, amount_paid, date_paid, semester_audit_id))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "payments", :action => "add_student_payment", :student_id => student_id
    else
      flash[:error] = "Unable to save the details. Check for the errors and try again"
      render :controller => "payments", :action => "add_student_payment", :student_id => student_id
    end
    
  end
  
end
