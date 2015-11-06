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
    notifications = {}
    semesters = Semester.all
    if (semesters.blank?)
      notifications["semesters"] = {} if notifications["semesters"].blank?
      notifications["semesters"]["link"] = "/semesters/semester_settings"
      notifications["semesters"]["caption"] = "Add Semesters"
    end

    current_semester = GlobalProperty.find_by_property("current_semester").value rescue nil
    if (current_semester.blank?)
      notifications["current_semester"] = {} if notifications["current_semester"].blank?
      notifications["current_semester"]["link"] = "/semesters/set_current_semester"
      notifications["current_semester"]["caption"] = "Set Current Semester"
    end

    students = Student.find_by_sql("SELECT s.* FROM student s LEFT JOIN student_archive sa
      ON s.student_id = sa.student_id WHERE sa.student_id IS NULL")
    if (students.blank?)
      notifications["students"] = {} if notifications["students"].blank?
      notifications["students"]["link"] = "/student/add_student/"
      notifications["students"]["caption"] = "Add Students"
    end

    payment_types = PaymentType.all
    if (payment_types.blank?)
      notifications["payment_types"] = {} if notifications["payment_types"].blank?
      notifications["payment_types"]["link"] = "/payment_types/add_payment_type"
      notifications["payment_types"]["caption"] = "Add Payment Type"
    end

    examination_types = ExaminationType.all
    if (examination_types.blank?)
      notifications["examination_types"] = {} if notifications["examination_types"].blank?
      notifications["examination_types"]["link"] = "/examination_type/new_exam_type"
      notifications["examination_types"]["caption"] = "Add Exam Types"
    end
    
    class_rooms = ClassRoom.all
    if (class_rooms.blank?)
      notifications["class_rooms"] = {} if notifications["class_rooms"].blank?
      notifications["class_rooms"]["link"] = "/class_room/add_class"
      notifications["class_rooms"]["caption"] = "Add Class Rooms"
    end

    courses = Course.all
    if (courses.blank?)
      notifications["courses"] = {} if notifications["courses"].blank?
      notifications["courses"]["link"] = "/course/add_course"
      notifications["courses"]["caption"] = "Add Courses"
    end

    teachers = Teacher.all
    if (teachers.blank?)
      notifications["teachers"] = {} if notifications["teachers"].blank?
      notifications["teachers"]["link"] = "/employees/add_employee/"
      notifications["teachers"]["caption"] = "Add Teachers"
    end

    school_name = GlobalProperty.find_by_property("school_name") rescue nil
    if (school_name).blank?
      notifications["school_name"] = {} if notifications["school_name"].blank?
      notifications["school_name"]["link"] = "/admin/settings"
      notifications["school_name"]["caption"] = "Add School Name"
    end

    school_logo = GlobalProperty.find_by_property('school_logo')
    if (school_logo.blank?)
      notifications["school_logo"] = {} if notifications["school_logo"].blank?
      notifications["school_logo"]["link"] = "/admin/add_logo"
      notifications["school_logo"]["caption"] = "Upload School Logo"
    end
    
    return notifications
  end
end
