class PaymentsController < ApplicationController

  def payments_management_menu
    render :layout => false
  end

  def payments_management_dashboard
    render :layout => false
  end

  def add_payment
    @students = Student.find(:all)
    render :layout => false
  end
  
  def edit_payment
    @students = Student.find(:all)
    render :layout => false
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
    
    render :layout => false
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
    
    render :layout => false
  end
  
  def void_payments
    @students = Student.find(:all)
    render :layout => false
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

    render :layout => false
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
    render :layout => false
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
    
    render :layout => false
  end
  
  def add_student_payment
    @student = Student.find(params[:student_id])

    @payment_types = [["[Payment Type]", ""]]
    @payment_types += PaymentType.all.collect{|c|[c.name, c.id]}
    
    @semesters = [["[Semester]", ""]]
    @semesters += Semester.all.collect{|s|[s.semester_number, s.id]}
    
    @current_student_payments = Payment.find(:all, :conditions => ["student_id =?",
        params[:student_id]])
    @current_semester_id = GlobalProperty.find_by_property("current_semester").value rescue ""

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
    
    render :layout => false
  end

  def create_student_payment
    student_id = params[:student_id]
    payment_type = params[:payment_type]
    semester = params[:semester]
    amount_paid = params[:amount]
    date_paid = params[:payment_date]
    if (Payment.create({
            :student_id => student_id,
            :payment_type_id => payment_type,
            :semester_id => semester,
            :amount_paid => amount_paid,
            :date => date_paid
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "payments", :action => "add_student_payment", :student_id => student_id
    else
      flash[:error] = "Unable to save the details. Check for the errors and try again"
      render :controller => "payments", :action => "add_student_payment", :student_id => student_id
    end
  end
  
end
