# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def notices
    #Students
    #Semesters
    #Current Semester
    #Payment Types
    #Class Rooms
    #Courses
    #Teachers
    #School Name
    #Punishment Type
    notifications = {}
    sort_weight = 0
    semesters = Semester.all
    if (semesters.blank?)
      sort_weight = sort_weight + 1
      notifications["semesters"] = {} if notifications["semesters"].blank?
      notifications["semesters"]["sort_weight"] = sort_weight
      notifications["semesters"]["link"] = "/semesters/semester_settings"
      notifications["semesters"]["caption"] = "Add Semesters"
    end

    current_semester = Semester.current_active_semester_audit
    if (current_semester.blank?)
      sort_weight = sort_weight + 1
      notifications["current_semester"] = {} if notifications["current_semester"].blank?
      notifications["current_semester"]["sort_weight"] = sort_weight
      notifications["current_semester"]["link"] = "/semesters/set_current_semester"
      notifications["current_semester"]["caption"] = "Set Current Semester"
    end

    students = Student.find_by_sql("SELECT s.* FROM student s LEFT JOIN student_archive sa
      ON s.student_id = sa.student_id WHERE sa.student_id IS NULL")
    if (students.blank?)
      sort_weight = sort_weight + 1
      notifications["students"] = {} if notifications["students"].blank?
      notifications["students"]["sort_weight"] = sort_weight
      notifications["students"]["link"] = "/student/add_student/"
      notifications["students"]["caption"] = "Add Students"
    end

    payment_types = PaymentType.all
    if (payment_types.blank?)
      sort_weight = sort_weight + 1
      notifications["payment_types"] = {} if notifications["payment_types"].blank?
      notifications["payment_types"]["sort_weight"] = sort_weight
      notifications["payment_types"]["link"] = "/payment_types/add_payment_type"
      notifications["payment_types"]["caption"] = "Add Payment Type"
    end

    examination_types = ExaminationType.all
    if (examination_types.blank?)
      sort_weight = sort_weight + 1
      notifications["examination_types"] = {} if notifications["examination_types"].blank?
      notifications["examination_types"]["sort_weight"] = sort_weight
      notifications["examination_types"]["link"] = "/examination_type/new_exam_type"
      notifications["examination_types"]["caption"] = "Add Exam Types"
    end
    
    class_rooms = ClassRoom.all
    if (class_rooms.blank?)
      sort_weight = sort_weight + 1
      notifications["class_rooms"] = {} if notifications["class_rooms"].blank?
      notifications["class_rooms"]["sort_weight"] = sort_weight
      notifications["class_rooms"]["link"] = "/class_room/add_class"
      notifications["class_rooms"]["caption"] = "Add Class Rooms"
    end

    courses = Course.all
    if (courses.blank?)
      sort_weight = sort_weight + 1
      notifications["courses"] = {} if notifications["courses"].blank?
      notifications["courses"]["sort_weight"] = sort_weight
      notifications["courses"]["link"] = "/course/add_course"
      notifications["courses"]["caption"] = "Add Courses"
    end

    teachers = Teacher.all
    if (teachers.blank?)
      sort_weight = sort_weight + 1
      notifications["teachers"] = {} if notifications["teachers"].blank?
      notifications["teachers"]["sort_weight"] = sort_weight
      notifications["teachers"]["link"] = "/employees/add_employee/"
      notifications["teachers"]["caption"] = "Add Teachers"
    end

    school_name = GlobalProperty.find_by_property("school_name") rescue nil
    if (school_name).blank?
      sort_weight = sort_weight + 1
      notifications["school_name"] = {} if notifications["school_name"].blank?
      notifications["school_name"]["sort_weight"] = sort_weight
      notifications["school_name"]["link"] = "/admin/settings"
      notifications["school_name"]["caption"] = "Add School Name"
    end

    school_logo = GlobalProperty.find_by_property('school_logo')
    if (school_logo.blank?)
      sort_weight = sort_weight + 1
      notifications["school_logo"] = {} if notifications["school_logo"].blank?
      notifications["school_logo"]["sort_weight"] = sort_weight
      notifications["school_logo"]["link"] = "/admin/add_logo"
      notifications["school_logo"]["caption"] = "Upload School Logo"
    end

    class_rooms = ClassRoom.all
    unless class_rooms.blank?
      class_without_courses = false
      class_rooms.each do |class_room|
        class_room_courses = class_room.class_room_courses
        if (class_room_courses.blank?)
          class_without_courses = true
          break
        end
      end

      if (class_without_courses == true)
        sort_weight = sort_weight + 1
        notifications["class_courses"] = {} if notifications["class_courses"].blank?
        notifications["class_courses"]["sort_weight"] = sort_weight
        notifications["class_courses"]["link"] = "/class_room/assign_subjects"
        notifications["class_courses"]["caption"] = "Assign Courses to Class Rooms"
      end
    end
    
    unless (students.blank?)
      students_without_classes = false
      students.each do |student|
        student_class_room_adjustments = student.student_class_room_adjustments
        if (student_class_room_adjustments.blank?)
          students_without_classes = true
          break
        end
      end

      if (students_without_classes == true)
        sort_weight = sort_weight + 1
        notifications["students_without_classes"] = {} if notifications["students_without_classes"].blank?
        notifications["students_without_classes"]["sort_weight"] = sort_weight
        notifications["students_without_classes"]["link"] = "/student/assign_class/"
        notifications["students_without_classes"]["caption"] = "Assign Classes to Students"
      end
    end

    unless (students.blank?)
      students_without_courses = false
      students.each do |student|
        next if student.current_class.blank? #Not Interested in students without classes
        latest_class_name = student.current_class #Returns Class Name
        class_room_id = ClassRoom.find_by_name(latest_class_name).class_room_id
        latest_student_courses = student.student_class_room_courses.find(:all,
          :conditions => ["class_room_id =?", class_room_id])
        if (latest_student_courses.blank?)
          students_without_courses = true
          break
        end
      end

      if (students_without_courses == true)
        sort_weight = sort_weight + 1
        notifications["students_without_courses"] = {} if notifications["students_without_courses"].blank?
        notifications["students_without_courses"]["sort_weight"] = sort_weight
        notifications["students_without_courses"]["link"] = "/student/assign_subjects"
        notifications["students_without_courses"]["caption"] = "Assign Courses to Students"
      end
    end

    punishment_types = PunishmentType.all
    if (punishment_types.blank?)
      sort_weight = sort_weight + 1
      notifications["punishment_types"] = {} if notifications["punishment_types"].blank?
      notifications["punishment_types"]["sort_weight"] = sort_weight
      notifications["punishment_types"]["link"] = "/punishments/add_punishment_type/"
      notifications["punishment_types"]["caption"] = "Add Punishment Types"
    end

    return notifications
  end

  def semester_data
    semester_audits = SemesterAudit.find(:all, :conditions => ["state IN (?)", ['close', 'open']], :order => 'semester_id ASC')

    semesters = semester_audits.collect do |semester_audit|
      semester_number = semester_audit.semester.semester_number
      semester_audit_id = semester_audit.semester_audit_id
      start_date = semester_audit.start_date.strftime("%d/%b/%Y") rescue  semester_audit.start_date
      end_date = semester_audit.end_date.strftime("%d/%b/%Y") rescue  semester_audit.end_date
      [semester_audit_id, semester_number, start_date, end_date]
    end

    return semesters
  end

  def years
    start_year = SemesterAudit.find(:all, :conditions => ["start_date IS NOT NULL"]).sort_by{|sa|
      sa.start_date.to_date rescue sa.start_date
    }.collect{|s| s.start_date.to_date.year rescue s.start_date}.first

    end_year= SemesterAudit.find(:all, :conditions => ["end_date IS NOT NULL"]).sort_by{|sa|
      sa.end_date.to_date rescue sa.end_date
    }.collect{|s| s.end_date.to_date.year rescue s.end_date}.last

    return [start_year, end_year].sort #Sort Just In case the start_year > end_year

  end

  def available_class_rooms
    class_rooms = ClassRoom.find(:all)
    data = []

    class_rooms.each do |class_room|
      class_room_id = class_room.class_room_id
      class_room_name = class_room.name
      data << [class_room_id, class_room_name]
    end
    
    return data
  end

  def student_notifications
    student_id = session[:current_student_id]
    student_notifications = StudentNotification.find(:all, :conditions => ["student_id =?", student_id])
    notifications_hash = {}
    new_examination_count = 0
    new_payment_count = 0
    new_examination_results_count = 0
    new_punishment_count = 0

    student_notifications.each do |notification|
      new_examination_count += 1 if notification.record_type.downcase.to_s == "new_examination" #To avoid matching with new_examination_results
      new_payment_count += 1 if notification.record_type.match(/new_payment/i)
      new_examination_results_count += 1 if notification.record_type.match(/new_examination_results/i)
      new_punishment_count += 1 if notification.record_type.match(/new_punishment/i)
    end

    notifications_count  = student_notifications.count

    notifications_hash[notifications_count] = {}
    
    notifications_hash[notifications_count]["new_examination"] = {
      "count" => new_examination_count,
      "caption" => "New Exams",
      "link" => "/student/student_new_examination_notifications",
      "sort_weight" => 1
    } if new_examination_count >= 1

    notifications_hash[notifications_count]["new_payment"] = {
      "count" => new_payment_count,
      "caption" => "New Payments",
      "link" => "/student/student_new_payment_notifications",
      "sort_weight" => 2
    } if new_payment_count >= 1

    notifications_hash[notifications_count]["new_examination_results"] = {
      "count" => new_examination_results_count,
      "caption" => "New Exam Results",
      "link" => "/student/student_new_exam_results_notifications",
      "sort_weight" => 3
    } if new_examination_results_count >= 1

    notifications_hash[notifications_count]["new_punishment"] = {
      "count" => new_punishment_count,
      "caption" => "New Punishments",
      "link" => "/student/student_new_punishments_notifications",
      "sort_weight" => 4
    } if new_punishment_count >= 1

    return notifications_hash
  end

  def guardian_notifications
    guardian_id = session[:current_guardian_id]
    guardian_notifications = GuardianNotification.find(:all, :conditions => ["guardian_id =?", guardian_id])
    notifications_hash = {}
    new_examination_count = 0
    new_payment_count = 0
    new_examination_results_count = 0
    new_punishment_count = 0

    guardian_notifications.each do |notification|
      new_examination_count += 1 if notification.record_type.downcase.to_s == "new_examination" #To avoid matching with new_examination_results
      new_payment_count += 1 if notification.record_type.match(/new_payment/i)
      new_examination_results_count += 1 if notification.record_type.match(/new_examination_results/i)
      new_punishment_count += 1 if notification.record_type.match(/new_punishment/i)
    end

    notifications_count = guardian_notifications.count
    
    notifications_hash[notifications_count] = {}
    
    notifications_hash[notifications_count]["new_examination"] = {
      "count" => new_examination_count,
      "caption" => "New Exams",
      "link" => "/parent/student_new_examination_notifications",
      "sort_weight" => 1
    } if new_examination_count >= 1

    notifications_hash[notifications_count]["new_payment"] = {
      "count" => new_payment_count,
      "caption" => "New Payments",
      "link" => "/parent/student_new_payment_notifications",
      "sort_weight" => 2
    } if new_payment_count >= 1

    notifications_hash[notifications_count]["new_examination_results"] = {
      "count" => new_examination_results_count,
      "caption" => "New Exam Results",
      "link" => "/parent/student_new_exam_results_notifications",
      "sort_weight" => 3
    } if new_examination_results_count >= 1
    
    notifications_hash[notifications_count]["new_punishment"] = {
      "count" => new_punishment_count,
      "caption" => "New Punishments",
      "link" => "/parent/student_new_punishments_notifications",
      "sort_weight" => 4
    } if new_punishment_count >= 1

    return notifications_hash
  end

  def user_roles_data
    username = User.find(session[:current_user_id]).username
    user_roles = UserRole.find(:all, :conditions => ["username =?", username], :order => "sort_weight ASC")
    user_role_hash = {}
    user_roles.each do |user_role|
      current_user_role = session[:current_user_role]
      next if user_role.role.match(/#{current_user_role}/i)
      role = user_role.role
      user_role_hash[role] = {}
      user_role_hash[role]["link"] = "/user/switch_role?role=#{role}"
    end

    return user_role_hash
  end
  
end
