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
    render :layout => false
  end

  def void_payments
    render :layout => false
  end

  def view_payments
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
    render :layout => false
  end
  
end
