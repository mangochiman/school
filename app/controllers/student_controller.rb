class StudentController < ApplicationController
  def index
    render :layout => false
  end

  def my_results
    render :layout => false
  end

  def add_student
    render :layout => false
  end

  def edit_student
    @students = Student.all
    render :layout => false
  end

  def remove_students
    render :layout => false
  end

  def assign_class
    render :layout => false
  end

  def assign_subjects
    render :layout => false
  end

  def assign_parent_guardian
    render :layout => false
  end
  
  def filter_students
    render :layout => false
  end

  def search_students
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = ""
    conditions = ""
=begin
    unless params[:gender].blank?
      gender = 'M' if (params[:gender].upcase == 'M')
      gender = 'F' if (params[:gender].upcase == 'F')
    end
=end
    unless first_name.blank?
      conditions += "fname LIKE '%#{first_name}%'"
    end
    
    unless last_name.blank?
      conditions += ' AND ' unless conditions.blank?
      conditions += "lname LIKE '%#{last_name}%' "
    end

    unless gender.blank?
      conditions += ' AND ' unless (first_name.blank? || last_name.blank?)
      conditions += "gender = '%#{gender}%' "
    end
    students = Student.find_by_sql("SELECT * FROM student WHERE #{conditions}")
    hash = {}
    students.each do |student|
      #student_id = student.id.to_s
      #hash[student_id] = {}
      #hash["fname"] = student.fname.to_s
      hash[:lname] = student.lname.to_s
      #hash[student_id]["phone"] = student.phone
      #hash[student_id]["email"] = student.email
      #hash[student_id]["dob"] = student.dob.to_date.strftime("%d-%b-%Y")
    end
    render :json => hash
  end
  
  def create
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    password = params[:password] #To be used later
    date_of_birth = params[:dob].to_date
    username = first_name.first.downcase.to_s + '' + last_name.squish.downcase #To be used later
    if (Student.create({
        :fname => first_name,
        :lname => last_name,
        :email => email,
        :phone => phone,
        :dob => date_of_birth
      }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "student", :action => "add_student"
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "student", :action => "add_student"
    end
  end
end
