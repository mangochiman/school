# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  before_filter :authenticate_user
  
  def school_setting
    settings = {}
    settings["name"] = GlobalProperty.find_by_property("name").value rescue ""
    return settings
  end

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
      notifications["semesters"]["view"] = "/semesters/index"
      notifications["semesters"]["caption"] = "Add Semester"
    end
    
    current_semester = GlobalProperty.find_by_property("current_semester").value rescue nil
    if (current_semester.blank?)
      notifications["current_semester"] = {} if notifications["current_semester"].blank?
      notifications["current_semester"]["view"] = "/semesters/index"
      notifications["current_semester"]["caption"] = "Set Current Semester"
    end

    students = Student.find_by_sql("SELECT s.* FROM student s LEFT JOIN student_archive sa
      ON s.student_id = sa.student_id WHERE sa.student_id IS NULL")
    if (students.blank)
      notifications["students"] = {} if notifications["students"].blank?
      notifications["students"]["view"] = "/students/add_student"
      notifications["students"]["caption"] = "Add Students"
    end
    
    payment_types = PaymentType.all
    if (payment_types.blank?)
      notifications["payment_types"] = {} if notifications["payment_types"].blank?
      notifications["payment_types"]["view"] = "/payment_types/add_payment_type"
      notifications["payment_types"]["caption"] = "Add Payment Type"
    end

    class_rooms = ClassRoom.all
    if (class_rooms.blank?)
      notifications["class_rooms"] = {} if notifications["class_rooms"].blank?
      notifications["class_rooms"]["view"] = "/class_room/add_class_room"
      notifications["class_rooms"]["caption"] = "Add Class Rooms"
    end

    courses = Course.all
    if (courses.blank?)
      notifications["courses"] = {} if notifications["courses"].blank?
      notifications["courses"]["view"] = "/class_room/add_class_room"
      notifications["courses"]["caption"] = "Add Courses"
    end

    teachers = Teacher.all
    if (teachers.blank?)
      notifications["teachers"] = {} if notifications["teachers"].blank?
      notifications["teachers"]["view"] = "/teachers/add_teacher"
      notifications["teachers"]["caption"] = "Add Teachers"
    end

    school_name = GlobalProperty.find_by_property("school_name") rescue nil
    if (school_name).blank?
      notifications["school_name"] = {} if notifications["school_name"].blank?
      notifications["school_name"]["view"] = "#"
      notifications["teachers"]["caption"] = "Add School Name"
    end
    
    return notifications
  end
  
  protected

  def authenticate_user
    user = User.find(session[:current_user_id]) rescue nil
    return true unless user.blank?
    access_denied
    return false
  end

  def access_denied
    #flash[:error] = 'Oops. You need to login before you can view that page.'
    redirect_to ("/user/login") and return
  end
 
end
