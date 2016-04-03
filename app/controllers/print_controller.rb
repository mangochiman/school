class PrintController < ApplicationController
  skip_before_filter :authenticate_user
  def student_performance_summary_print

    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    @class_room_hash = {}
    class_rooms = ClassRoom.find(:all)
    class_rooms.each do |c|
      @class_room_hash[c.id] = c.name
    end

    current_class_room_id = ""
    active_class_adjustment = @student.student_class_room_adjustments.find(:last,
      :conditions => ["status =?", 'active'])
    current_class_room_id = active_class_adjustment.new_class_room_id unless active_class_adjustment.blank?

    @exams_hash = {}

    (@student.exam_attendees || []).each do |exam_attendee|
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
            exam_attendee.examination.id, @student.student_id])
        exam_results = result.marks unless result.blank?
      end

      @exams_hash[class_room_id] = {} if @exams_hash[class_room_id].blank?
      @exams_hash[class_room_id][exam_id] = {} if @exams_hash[class_room_id][exam_id].blank?
      @exams_hash[class_room_id][exam_id]["exam_type"] = exam_type
      @exams_hash[class_room_id][exam_id]["course"] = course_name
      @exams_hash[class_room_id][exam_id]["exam_date"] = exam_date
      @exams_hash[class_room_id][exam_id]["exam_results"] = exam_results
      @exams_hash[class_room_id][exam_id]["status"] = status

    end
    render :layout => false
  end

  def print_to_pdf_student_performance_summary_print
    destination_path = "/tmp/student_performance_summary.pdf"
    print_path = "/print/student_performance_summary_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_payments_summary_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    @payment_hash = {}

    (@student.payments || []).each do |payment|
      semester_audit_id = payment.semester_audit_id
      payment_id = payment.id
      payment_type = payment.payment_type_id
      date_paid = payment.date
      amount_paid = payment.amount_paid
      amount_required = payment.payment_type.amount_required
      @payment_hash[semester_audit_id] = {} if @payment_hash[semester_audit_id].blank?
      @payment_hash[semester_audit_id][payment_type] = {} if @payment_hash[semester_audit_id][payment_type].blank?
      @payment_hash[semester_audit_id][payment_type][payment_id] = {} if @payment_hash[semester_audit_id][payment_type][payment_id].blank?
      @payment_hash[semester_audit_id][payment_type][payment_id]["date_paid"] = date_paid
      @payment_hash[semester_audit_id][payment_type][payment_id]["amount_paid"] = amount_paid
      @payment_hash[semester_audit_id][payment_type]["balance"] = amount_required.to_i if @payment_hash[semester_audit_id][payment_type]["balance"].blank?
      @payment_hash[semester_audit_id][payment_type]["balance"] -= amount_paid.to_i
      @payment_hash[semester_audit_id][payment_type]["amount_required"] = amount_required.to_i
      @payment_hash[semester_audit_id][payment_type]["total_payments"] = 0 if @payment_hash[semester_audit_id][payment_type]["total_payments"].blank?
      @payment_hash[semester_audit_id][payment_type]["total_payments"] += amount_paid.to_i
    end

    render :layout => false
  end

  def print_to_pdf_student_payments_summary_print
    destination_path = "/tmp/student_payments_summary.pdf"
    print_path = "/print/student_payments_summary_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_punishments_summary_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    @punishment_hash = {}
    (@student.student_punishments || []).each do |student_punishment|
      punishment_id = student_punishment.punishment.id
      punishment_type = student_punishment.punishment.punishment_type.name
      start_date = student_punishment.punishment.start_date
      end_date = student_punishment.punishment.end_date
      punishment_details = student_punishment.punishment.details
      status = 'No'
      status = 'Yes' if student_punishment.completed.to_i == 1
      @punishment_hash[punishment_id] = {}
      @punishment_hash[punishment_id]["punishment_type"] = punishment_type
      @punishment_hash[punishment_id]["details"] = punishment_details
      @punishment_hash[punishment_id]["start_date"] = start_date
      @punishment_hash[punishment_id]["end_date"] = end_date
      @punishment_hash[punishment_id]["completed"] = status
    end

    render :layout => false
  end

  def print_to_pdf_student_punishments_summary_print
    destination_path = "/tmp/student_punishments_summary.pdf"
    print_path = "/print/student_punishments_summary_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_new_examination_notifications_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    student_id = @student.student_id

    examination_notifications = StudentNotification.find(:all, :conditions => ["student_id =? AND
      record_type =?", student_id, 'new_examination'])

    @notifications_hash = {}
    examination_notifications.each do |notifications|
      exam_id = notifications.record_id
      student_exam_attendance_record = ExamAttendee.find(:last, :conditions => ["exam_id =? AND
            student_id =?", exam_id, student_id])
      unless student_exam_attendance_record.blank?
        exam = Examination.find(exam_id)
        @notifications_hash[exam_id] = {}
        @notifications_hash[exam_id]["exam_type"] = exam.examination_type.name
        @notifications_hash[exam_id]["course"] = exam.course.name
        @notifications_hash[exam_id]["exam_date"] = exam.start_date
      end
    end

    render :layout => false
  end

  def print_to_pdf_student_new_examination_notifications_print
    destination_path = "/tmp/student_new_examination_notifications.pdf"
    print_path = "/print/student_new_examination_notifications_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_new_exam_results_notifications_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    student_id = @student.student_id

    exam_results_notifications = StudentNotification.find(:all, :conditions => ["student_id =? AND
      record_type =?", student_id, 'new_examination_results'])

    @notifications_hash = {}
    exam_results_notifications.each do |notifications|
      exam_result_id = notifications.record_id
      exam_result_record = ExaminationResult.find(:last, :conditions => ["exam_result_id =? AND
            student_id =?", exam_result_id, student_id])
      unless exam_result_record.blank?
        exam_result = ExaminationResult.find(exam_result_id)
        @notifications_hash[exam_result_id] = {}
        @notifications_hash[exam_result_id]["exam_type"] = exam_result.examination.examination_type.name
        @notifications_hash[exam_result_id]["course"] = exam_result.examination.course.name
        @notifications_hash[exam_result_id]["exam_date"] = exam_result.examination.start_date
        @notifications_hash[exam_result_id]["exam_result"] = exam_result.marks
      end
    end

    render :layout => false
  end

  def print_to_pdf_student_new_exam_results_notifications_print
    destination_path = "/tmp/student_new_exam_results_notifications.pdf"
    print_path = "/print/student_new_exam_results_notifications_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_new_payment_notifications_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    student_id = @student.student_id
    payments_notifications = StudentNotification.find(:all, :conditions => ["student_id =? AND
      record_type =?", student_id, 'new_payment'])

    @notifications_hash = {}
    payments_notifications.each do |notifications|
      payment_id = notifications.record_id
      student_payment_record = Payment.find(:last, :conditions => ["payment_id =? AND
            student_id =?", payment_id, student_id])
      unless student_payment_record.blank?
        payment = Payment.find(payment_id)
        @notifications_hash[payment_id] = {}
        @notifications_hash[payment_id]["payment_type"] = payment.payment_type.name
        @notifications_hash[payment_id]["amount_paid"] = payment.amount_paid
        @notifications_hash[payment_id]["date_paid"] = payment.date
      end
    end

    render :layout => false
  end

  def print_to_pdf_student_new_payment_notifications_print
    destination_path = "/tmp/student_new_payment_notifications.pdf"
    print_path = "/print/student_new_payment_notifications_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_new_punishments_notifications_print
    if params[:student_id].blank?
      @student = Student.find(session[:current_student_id])
    else
      @student = Student.find(params[:student_id]) #wkhtmltopdf does not recognize session variables
    end
    
    student_id = @student.student_id

    punishments_notifications = StudentNotification.find(:all, :conditions => ["student_id =? AND
      record_type =?", student_id, 'new_punishment'])

    @notifications_hash = {}
    punishments_notifications.each do |notifications|
      punishment_id = notifications.record_id
      student_punishment_record = StudentPunishment.find(:last, :conditions => ["punishment_id =? AND
            student_id =?", punishment_id, student_id])
      unless student_punishment_record.blank?
        punishment = Punishment.find(punishment_id)
        @notifications_hash[punishment_id] = {}
        @notifications_hash[punishment_id]["punishment_type"] = punishment.punishment_type.name
        @notifications_hash[punishment_id]["punishment_details"] = punishment.details
        @notifications_hash[punishment_id]["start_date"] = punishment.start_date
        @notifications_hash[punishment_id]["end_date"] = punishment.end_date
      end
    end

    render :layout => false
  end

  def print_to_pdf_student_new_punishments_notifications_print
    destination_path = "/tmp/student_new_punishments_notifications.pdf"
    print_path = "/print/student_new_punishments_notifications_print"
    student_id = session[:current_student_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  #>>>>>>>>>>>>>>>>>>>>>>>>>>>GUARDIAN METHODS>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  def guardian_student_performance_summary_print
    #@guardian = Parent.find(session[:current_guardian_id])
    @guardian = Parent.find(params[:guardian_id])
    @student = Student.find(params[:student_id])

    @class_room_hash = {}
    class_rooms = ClassRoom.find(:all)
    class_rooms.each do |c|
      @class_room_hash[c.id] = c.name
    end

    current_class_room_id = ""
    active_class_adjustment = @student.student_class_room_adjustments.find(:last,
      :conditions => ["status =?", 'active'])
    current_class_room_id = active_class_adjustment.new_class_room_id unless active_class_adjustment.blank?

    @exams_hash = {}

    (@student.exam_attendees || []).each do |exam_attendee|
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
            exam_attendee.examination.id, @student.student_id])
        exam_results = result.marks unless result.blank?
      end

      @exams_hash[class_room_id] = {} if @exams_hash[class_room_id].blank?
      @exams_hash[class_room_id][exam_id] = {} if @exams_hash[class_room_id][exam_id].blank?
      @exams_hash[class_room_id][exam_id]["exam_type"] = exam_type
      @exams_hash[class_room_id][exam_id]["course"] = course_name
      @exams_hash[class_room_id][exam_id]["exam_date"] = exam_date
      @exams_hash[class_room_id][exam_id]["exam_results"] = exam_results
      @exams_hash[class_room_id][exam_id]["status"] = status

    end
    
    render :layout => false
  end

  def print_to_pdf_guardian_student_performance_summary_print
    destination_path = "/tmp/guardian_student_performance_summary.pdf"
    print_path = "/print/guardian_student_performance_summary_print"
    student_id = params[:student_id]
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}&guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_payments_summary_print
    #@guardian = Parent.find(session[:current_guardian_id])
    @guardian = Parent.find(params[:guardian_id])
    @student = Student.find(params[:student_id])

    @payment_hash = {}

    (@student.payments || []).each do |payment|
      semester_audit_id = payment.semester_audit_id
      payment_id = payment.id
      payment_type = payment.payment_type_id
      date_paid = payment.date
      amount_paid = payment.amount_paid
      amount_required = payment.payment_type.amount_required
      @payment_hash[semester_audit_id] = {} if @payment_hash[semester_audit_id].blank?
      @payment_hash[semester_audit_id][payment_type] = {} if @payment_hash[semester_audit_id][payment_type].blank?
      @payment_hash[semester_audit_id][payment_type][payment_id] = {} if @payment_hash[semester_audit_id][payment_type][payment_id].blank?
      @payment_hash[semester_audit_id][payment_type][payment_id]["date_paid"] = date_paid
      @payment_hash[semester_audit_id][payment_type][payment_id]["amount_paid"] = amount_paid
      @payment_hash[semester_audit_id][payment_type]["balance"] = amount_required.to_i if @payment_hash[semester_audit_id][payment_type]["balance"].blank?
      @payment_hash[semester_audit_id][payment_type]["balance"] -= amount_paid.to_i
      @payment_hash[semester_audit_id][payment_type]["amount_required"] = amount_required.to_i
      @payment_hash[semester_audit_id][payment_type]["total_payments"] = 0 if @payment_hash[semester_audit_id][payment_type]["total_payments"].blank?
      @payment_hash[semester_audit_id][payment_type]["total_payments"] += amount_paid.to_i
    end
    
    render :layout => false
  end

  def print_to_pdf_guardian_student_payments_summary_print
    destination_path = "/tmp/guardian_student_payments_summary.pdf"
    print_path = "/print/guardian_student_payments_summary_print"
    student_id = params[:student_id]
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}&guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_punishments_summary_print
    #@guardian = Parent.find(session[:current_guardian_id])
    @guardian = Parent.find(params[:guardian_id])
    @student = Student.find(params[:student_id])

    @punishment_hash = {}
    (@student.student_punishments || []).each do |student_punishment|
      punishment_id = student_punishment.punishment.id
      punishment_type = student_punishment.punishment.punishment_type.name
      start_date = student_punishment.punishment.start_date
      end_date = student_punishment.punishment.end_date
      punishment_details = student_punishment.punishment.details
      status = 'No'
      status = 'Yes' if student_punishment.completed.to_i == 1
      @punishment_hash[punishment_id] = {}
      @punishment_hash[punishment_id]["punishment_type"] = punishment_type
      @punishment_hash[punishment_id]["details"] = punishment_details
      @punishment_hash[punishment_id]["start_date"] = start_date
      @punishment_hash[punishment_id]["end_date"] = end_date
      @punishment_hash[punishment_id]["completed"] = status
    end
    render :layout => false
  end

  def print_to_pdf_guardian_student_punishments_summary_print
    destination_path = "/tmp/guardian_student_punishments_summary.pdf"
    print_path = "/print/guardian_student_punishments_summary_print"
    student_id = params[:student_id]
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?student_id=#{student_id}&guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_new_examination_notifications_print
    if params[:guardian_id].blank?
      @guardian = Parent.find(session[:current_guardian_id])
    else
      @guardian = Parent.find(params[:guardian_id])
    end

    guardian_id = @guardian.parent_id
    my_students = @guardian.students
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

    render :layout => false
  end

  def print_to_pdf_guardian_student_new_examination_notifications_print
    destination_path = "/tmp/guardian_student_new_examination_notifications.pdf"
    print_path = "/print/guardian_student_new_examination_notifications_print"
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_new_payment_notifications_print
    if params[:guardian_id].blank?
      @guardian = Parent.find(session[:current_guardian_id])
    else
      @guardian = Parent.find(params[:guardian_id])
    end
    
    guardian_id = @guardian.parent_id
    my_students = @guardian.students
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

    render :layout => false
  end

  def print_to_pdf_guardian_student_new_payment_notifications_print
    destination_path = "/tmp/guardian_student_new_payment_notifications.pdf"
    print_path = "/print/guardian_student_new_payment_notifications_print"
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_new_exam_results_notifications_print
    if params[:guardian_id].blank?
      @guardian = Parent.find(session[:current_guardian_id])
    else
      @guardian = Parent.find(params[:guardian_id])
    end

    guardian_id = @guardian.parent_id
    my_students = @guardian.students
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
          @notifications_hash[student_id][exam_result_id]["exam_type"] = exam_result.examination.examination_type.name
          @notifications_hash[student_id][exam_result_id]["course"] = exam_result.examination.course.name
          @notifications_hash[student_id][exam_result_id]["exam_date"] = exam_result.examination.start_date
          @notifications_hash[student_id][exam_result_id]["exam_result"] = exam_result.marks
        end
      end
    end

    render :layout => false
  end

  def print_to_pdf_guardian_student_new_exam_results_notifications_print
    destination_path = "/tmp/guardian_student_new_exam_results_notifications.pdf"
    print_path = "/print/guardian_student_new_exam_results_notifications_print"
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def guardian_student_new_punishments_notifications_print
    if params[:guardian_id].blank?
      @guardian = Parent.find(session[:current_guardian_id])
    else
      @guardian = Parent.find(params[:guardian_id])
    end

    guardian_id = @guardian.parent_id
    my_students = @guardian.students
    punishments_notifications = GuardianNotification.find(:all, :conditions => ["guardian_id =? AND
      record_type =?", guardian_id, 'new_punishment'])
    @notifications_hash = {}

    my_students.each do |student|
      student_id = student.student_id
      @notifications_hash[student_id] = {}
      punishments_notifications.each do |notifications|
        punishment_id = notifications.record_id
        student_punishment_record = StudentPunishment.find(:last, :conditions => ["punishment_id =? AND
            student_id =?", punishment_id, student_id])
        unless student_punishment_record.blank?
          punishment = Punishment.find(punishment_id)
          @notifications_hash[student_id][punishment_id] = {}
          @notifications_hash[student_id][punishment_id]["punishment_type"] = punishment.punishment_type.name
          @notifications_hash[student_id][punishment_id]["punishment_details"] = punishment.details
          @notifications_hash[student_id][punishment_id]["start_date"] = punishment.start_date
          @notifications_hash[student_id][punishment_id]["end_date"] = punishment.end_date
        end
      end
    end

    render :layout => false
  end

  def print_to_pdf_guardian_student_new_punishments_notifications_print
    destination_path = "/tmp/guardian_student_new_punishments_notifications.pdf"
    print_path = "/print/guardian_student_new_punishments_notifications_print"
    guardian_id = session[:current_guardian_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?guardian_id=#{guardian_id}" + "\" #{destination_path} \n"
    }
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  #>>>>>>>>>>>>>>>>>>>>>>>>>>>REPORTS>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  def students_per_semester_report_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    semester_audit_id = params[:semester_audit_id]
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}
    students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}")

    students.each do |student|
      student_id  = student.id
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id] = {}
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["class_room"] = student.current_class #class room name
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_students_per_semester_report_print
    destination_path = "/tmp/students_per_semester_report.pdf"
    print_path = "/print/students_per_semester_report_print"
    semester_audit_id = params[:semester_audit_id]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?semester_audit_id=#{semester_audit_id}" + "\" #{destination_path} \n"
    }
    
    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_per_year_report_print
    hash = {}
    students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id INNER JOIN semester_audit sa
          ON scra.semester_audit_id = sa.semester_audit_id WHERE
          (DATE_FORMAT(sa.start_date, '%Y') = #{params[:year]} OR  DATE_FORMAT(sa.end_date, '%Y') = #{params[:year]})
          GROUP BY s.student_id, DATE_FORMAT(sa.start_date, '%Y')")

    students.each do |student|
      student_id  = student.id
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id] = {}
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["class_room"] = student.current_class #class room name
    end

    @report_hash = hash

    render :layout => false
  end

  def print_to_pdf_students_per_year_report_print
    destination_path = "/tmp/students_per_year_report.pdf"
    print_path = "/print/students_per_year_report_print"
    year = params[:year]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?year=#{year}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_per_class_report_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    class_room_id = params[:class_room_id]
    semester_audit_id = params[:semester_audit_id]
    @class_name = ClassRoom.find(class_room_id).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}
    students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra
          ON s.student_id = scra.student_id INNER JOIN semester_audit sa
          ON scra.semester_audit_id = sa.semester_audit_id
          WHERE scra.new_class_room_id='#{class_room_id}' AND scra.semester_audit_id = '#{semester_audit_id}'")

    students.each do |student|
      student_id  = student.id
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id] = {}
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["class_room"] = student.name #class room name
    end

    @class_rooms = ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    @report_hash = hash

    render :layout => false
  end

  def print_to_pdf_students_per_class_report_print
    destination_path = "/tmp/students_per_class_report.pdf"
    print_path = "/print/students_per_class_report_print"
    class_room_id = params[:class_room_id]
    semester_audit_id = params[:semester_audit_id]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?class_room_id=#{class_room_id}&semester_audit_id=#{semester_audit_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def courses_report_print
    year = params[:year]
    if (year.match(/ALL/i))
      year = (start_year..end_year).to_a.join(', ')
    end
    courses = Course.find_by_sql("SELECT * FROM course WHERE DATE_FORMAT(created_at, '%Y') IN (#{year})")
    hash = {}

    (courses || []).each do |course|
      course_id = course.course_id
      hash[course_id] = {}
      hash[course_id]["course_name"] = course.name
      hash[course_id]["date_created"] = course.created_at.strftime("%d-%b-%Y")
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_courses_report_print
    destination_path = "/tmp/courses_report.pdf"
    print_path = "/print/courses_report_print"
    year = params[:year]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?year=#{year}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def courses_per_class_report_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    class_room_id = params[:class_room_id]
    semester_audit_id = params[:semester_audit_id]
    @class_name = ClassRoom.find(class_room_id).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}
    courses = Course.find_by_sql("SELECT c.course_id, c.name, c.created_at FROM course c INNER JOIN class_room_course crc ON
            c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.class_room_id
            INNER JOIN student_class_room_adjustment scra ON scra.new_class_room_id = cr.class_room_id
            INNER JOIN semester_audit sa ON scra.semester_audit_id = sa.semester_audit_id
            WHERE scra.new_class_room_id = '#{class_room_id}' AND sa.semester_audit_id = #{semester_audit_id}")

    courses.each do |course|
      course_id  = course.course_id
      course_name = course.name
      date_created = course.created_at.strftime("%d-%b-%Y")
      hash[course_id] = {}
      hash[course_id]["course_name"] = course_name
      hash[course_id]["date_created"] = date_created
    end

    @class_rooms = ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end
    
    @report_hash = hash

    render :layout => false
  end

  def print_to_pdf_courses_per_class_report_print
    destination_path = "/tmp/courses_per_class_report.pdf"
    print_path = "/print/courses_per_class_report_print"

    class_room_id = params[:class_room_id]
    semester_audit_id = params[:semester_audit_id]
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?class_room_id=#{class_room_id}&semester_audit_id=#{semester_audit_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def teachers_report_print

    start_date = params[:start_date]
    end_date = params[:end_date]
    teachers = Teacher.find(:all, :conditions => ["DATE(created_at) >= ? AND DATE(created_at) <= ?",
        start_date.to_date, end_date.to_date])
    hash = {}
    (teachers || []).each do |teacher|
      teacher_id = teacher.teacher_id
      teacher_name = teacher.fname.capitalize.to_s + ' ' + teacher.lname.capitalize.to_s
      hash[teacher_id] = {}
      hash[teacher_id]["name"] = teacher_name
      hash[teacher_id]["dob"] = teacher.dob
      hash[teacher_id]["email"] = teacher.email
      hash[teacher_id]["gender"] = teacher.gender
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_teachers_report_print
    destination_path = "/tmp/teachers_report.pdf"
    print_path = "/print/teachers_report_print"
    start_date = params[:start_date]
    end_date = params[:end_date]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?start_date=#{start_date}&end_date=#{end_date}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def teachers_per_subjects_report_print
    hash = {}
    class_rooms = ClassRoom.all
    @teacher_details = 'ALL' if (params[:teacher_id].match(/ALL/i))
    @teacher_details = Teacher.find(params[:teacher_id]).name_and_gender unless (params[:teacher_id].match(/ALL/i))
    if (params[:teacher_id].match(/ALL/i))
      teachers = Teacher.all
      teachers.each do |teacher|
        teacher_id = teacher.teacher_id
        hash[teacher_id] = {}
        class_rooms.each do |class_room|
          class_room_id = class_room.class_room_id
          hash[teacher_id][class_room_id] = {}
          courses = []

          teacher_class_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", teacher.teacher_id, class_room.class_room_id])

          (teacher_class_courses || []).each do |tcc|
            courses << tcc.course.name
          end

          count = 0
          row_hash = {}
          courses.in_groups_of(5).each do |group|
            count = count + 1
            row_hash[count] = group.compact
          end

          hash[teacher_id][class_room_id]["courses"] = row_hash unless courses.blank?
          hash[teacher_id].delete(class_room_id) if hash[teacher_id][class_room_id].blank?
        end
      end
    else
      teacher_id = params[:teacher_id]
      hash[teacher_id] = {}
      class_rooms.each do |class_room|
        class_room_id = class_room.class_room_id
        hash[teacher_id][class_room_id] = {}
        courses = []

        teacher_class_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", teacher_id, class_room.class_room_id])

        (teacher_class_courses || []).each do |tcc|
          courses << tcc.course.name
        end
        count = 0
        row_hash = {}
        courses.in_groups_of(5).each do |group|
          count = count + 1
          row_hash[count] = group.compact
        end

        hash[teacher_id][class_room_id]["courses"] = row_hash unless courses.blank?
        hash[teacher_id].delete(class_room_id) if hash[teacher_id][class_room_id].blank?
      end
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_teachers_per_subjects_report_print
    destination_path = "/tmp/teachers_per_subjects_report.pdf"
    print_path = "/print/teachers_per_subjects_report_print"
    teacher_id = params[:teacher_id]
    
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?teacher_id=#{teacher_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def student_performance_report_menu_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    exam_type = params[:exam_type]
    course = params[:course]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]
    @class_name = ClassRoom.find(class_room_id).name
    @exam_type_name = ExaminationType.find(exam_type).name
    @course_name = Course.find(course).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}

    students = Student.find_by_sql("SELECT s.*, e.start_date as exam_date, er.marks as grade FROM exam e
          LEFT JOIN exam_result er ON e.exam_id = er.exam_id
          INNER JOIN student_class_room_adjustment scra ON e.class_room_id = scra.new_class_room_id
          INNER JOIN student s ON scra.student_id = s.student_id
          INNER JOIN semester_audit sa ON scra.semester_audit_id = sa.semester_audit_id
          WHERE e.class_room_id = '#{class_room_id}' AND e.exam_type_id = '#{exam_type}' AND e.course_id = '#{course}'
          AND scra.semester_audit_id = '#{semester_audit_id}'" )

    students.each do |student|
      student_id = student.student_id
      hash[student_id] = {}
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["exam_date"] = student.exam_date.to_date.strftime("%d-%b-%Y")
      hash[student_id]["grade"] = student.grade
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_student_performance_report_menu_print
    destination_path = "/tmp/student_performance_report_menu.pdf"
    print_path = "/print/student_performance_report_menu_print"
    exam_type = params[:exam_type]
    course = params[:course]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]
    @class_name = ClassRoom.find(class_room_id).name
    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?exam_type=#{exam_type}&course=#{course}&semester_audit_id=#{semester_audit_id}&class_room_id=#{class_room_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_with_balances_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    
    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]
    @class_name = ClassRoom.find(class_room_id).name
    @payment_type_name = PaymentType.find(payment_type).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}

    students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE scra.new_class_room_id = '#{class_room_id}' AND
              p.semester_audit_id = '#{semester_audit_id}' AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid < amount_required")

    students.each do |student|
      student_id = student.student_id
      total_amount_paid = student.total_amount_paid
      hash[student_id] = {}
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["total_amount_paid"] = ActionController::Base.helpers.number_to_currency(total_amount_paid, :unit => 'MK')
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_students_with_balances_print
    destination_path = "/tmp/students_with_balances.pdf"
    print_path = "/print/students_with_balances_print"

    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?payment_type=#{payment_type}&semester_audit_id=#{semester_audit_id}&class_room_id=#{class_room_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_without_balances_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]
    @class_name = ClassRoom.find(class_room_id).name
    @payment_type_name = PaymentType.find(payment_type).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}
    students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE scra.new_class_room_id = #{class_room_id} AND
              p.semester_audit_id = '#{semester_audit_id}' AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid >= amount_required")

    students.each do |student|
      student_id = student.student_id
      total_amount_paid = student.total_amount_paid
      hash[student_id] = {}
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[student_id]["name"] = student_name
      hash[student_id]["dob"] = student.dob
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["total_amount_paid"] = ActionController::Base.helpers.number_to_currency(total_amount_paid, :unit => 'MK')
    end
    
    @report_hash = hash
    render :layout => false
  end
  
  def print_to_pdf_students_without_balances_print
    destination_path = "/tmp/students_without_balances.pdf"
    print_path = "/print/students_without_balances_print"
    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?payment_type=#{payment_type}&semester_audit_id=#{semester_audit_id}&class_room_id=#{class_room_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_without_payments_print
    current_semester_audit = Semester.current_active_semester_audit
    @current_semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    @current_semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?

    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]
    @class_name = ClassRoom.find(class_room_id).name
    @formatted_semester_details = SemesterAudit.formatted_semester_details(semester_audit_id)
    hash = {}
    hash[class_room_id] = {}
    students_who_paid_ids = students_who_paid(semester_audit_id, class_room_id, payment_type).join(', ')
    students_who_paid_ids = '0' if students_who_paid_ids.blank?

    students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra
              ON s.student_id = scra.student_id
              INNER JOIN semester_audit sa ON scra.semester_audit_id = sa.semester_audit_id
              WHERE scra.new_class_room_id = #{class_room_id} AND sa.semester_audit_id = '#{semester_audit_id}'
              AND s.student_id NOT IN (#{students_who_paid_ids})")

    students.each do |student|
      student_id = student.student_id
      hash[class_room_id][student_id] = {}
      student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
      hash[class_room_id][student_id]["name"] = student_name
      hash[class_room_id][student_id]["dob"] = student.dob
      hash[class_room_id][student_id]["email"] = student.email
      hash[class_room_id][student_id]["gender"] = student.gender
    end

    @report_hash = hash
    render :layout => false
  end

  def print_to_pdf_students_without_payments_print
    destination_path = "/tmp/students_without_payments.pdf"
    print_path = "/print/students_without_payments_print"
    payment_type = params[:payment_type]
    semester_audit_id = params[:semester_audit_id]
    class_room_id = params[:class_room_id]

    thread = Thread.new{
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
        request.env["HTTP_HOST"] + "\"#{print_path}/?payment_type=#{payment_type}&semester_audit_id=#{semester_audit_id}&class_room_id=#{class_room_id}" + "\" #{destination_path} \n"
    }

    thread.join #Make sure the thread is done
    send_file "#{destination_path}", :disposition => "attachment"
  end

  def students_who_paid(semester_audit_id, class_room_id, payment_type)
    students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE scra.new_class_room_id = #{class_room_id} AND
              p.semester_audit_id = '#{semester_audit_id}' AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid > 0")

    return students.map(&:student_id)

  end
end
