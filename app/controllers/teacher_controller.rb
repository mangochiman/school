class TeacherController < ApplicationController
  def index
    @teachers = Teacher.find(:all, :limit => 5)
    render :layout => false
  end

  def add_teacher
    render :layout => false
  end

  def assign_class
     render :layout => false
  end

  def teacher_stats
     render :layout => false
  end

  def assign_subjects
     render :layout => false
  end

  def filter_teachers
     render :layout => false
  end

  def edit_teacher
    if request.post?
      teacher = Teacher.find(params[:teacher_id])
      teacher.fname = params[:fname]
      teacher.lname = params[:lname]
      teacher.gender = params[:gender]
      teacher.mobile = params[:mobile]
      teacher.phone = params[:phone]
      teacher.dob = params[:dob]
      teacher.gender = params[:gender]
      teacher.email = params[:email]
      if teacher.save
        flash[:notice] = "You have successfully edited the details"
      else
        flash[:error] = "Teacher #{fname} #{lname} could not be edited"
      end
      @teacher = teacher
    else
        @teacher = Teacher.find(params[:id])
    end
    @male = ""
    @female = ""

    if @teacher.gender.upcase == "MALE"
      @male = "checked"
    end

    if @teacher.gender.upcase == "FEMALE"
      @female = "checked"
    end
     render :layout => false
  end
  def create
    if Teacher.create(:email => params[:email],
                            :password => params[:password],
                            :fname => params[:first_name],
                            :lname => params[:last_name],
                            :dob => params[:dob].to_date,
                            :gender => params[:gender],
                            :phone => params[:phone],
                            :mobile => params[:mobile],
                            :status => params[:status])
      flash[:notice] = "Teacher successfully added"
    else
       flash[:error] = "Unable to save. Check for errors and try again"
    end
    redirect_to :controller => "teacher", :action => "add_teacher"
  end
end
