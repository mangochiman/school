class PrintController < ApplicationController
  def student_performance_summary_print
    @student = Student.find(session[:current_student_id])

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

  def student_payments_summary_print
    @student = Student.find(session[:current_student_id])
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

  def student_punishments_summary_print
    @student = Student.find(session[:current_student_id])
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

  def student_new_examination_notifications_print
    @student = Student.find(session[:current_student_id])
    student_id = session[:current_student_id]

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

  def student_new_exam_results_notifications_print
    @student = Student.find(session[:current_student_id])
    student_id = session[:current_student_id]

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

  def student_new_payment_notifications_print
    @student = Student.find(session[:current_student_id])
    student_id = session[:current_student_id]
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

  def student_new_punishments_notifications_print
    @student = Student.find(session[:current_student_id])
    student_id = session[:current_student_id]

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

  #>>>>>>>>>>>>>>>>>>>>>>>>>>>GUARDIAN METHODS>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  def guardian_student_performance_summary_print
    @guardian = Parent.find(session[:current_guardian_id])
    @students = @guardian.students
    render :layout => "guardians"
  end

  def guardian_student_payments_summary_print
    @guardian = Parent.find(session[:current_guardian_id])
    @students = @guardian.students
    render :layout => "guardians"
  end

  def guardian_student_punishments_summary_print
    @guardian = Parent.find(session[:current_guardian_id])
    @students = @guardian.students
    render :layout => "guardians"
  end

  def guardian_student_new_examination_notifications_print
    @guardian = Parent.find(session[:current_guardian_id])
    guardian_id = session[:current_guardian_id]
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

    render :layout => "guardians"
  end

  def guardian_student_new_payment_notifications_print
    @guardian = Parent.find(session[:current_guardian_id])
    guardian_id = session[:current_guardian_id]
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

    render :layout => "guardians"
  end

  def guardian_student_new_exam_results_notifications_print
    @guardian = Parent.find(session[:current_guardian_id])
    guardian_id = session[:current_guardian_id]
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

    render :layout => "guardians"
  end

  def guardian_student_new_punishments_notifications_print
    @guardian = Parent.find(session[:current_guardian_id])
    guardian_id = session[:current_guardian_id]
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

    render :layout => "guardians"
  end

end
