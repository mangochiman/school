class UserController < ApplicationController
  skip_before_filter :authenticate_user, :only => [:login, :authenticate]
  def login
    @school_name = GlobalProperty.find_by_property("school_name") rescue nil
    # @settings = school_setting
    render :layout => false
  end

  def logout
    session[:current_user_id] = nil
    flash[:notice] = "You have been logged out"
    redirect_to :controller => "user", :action => "login" and return
  end
  
  def authenticate
    user = User.find_by_username(params['username'])
    logged_in_user = User.authenticate(params[:username], params[:password])
    if logged_in_user
      session[:current_user_id] = user.id
      user_role = user.user_roles.find(:all, :order => "sort_weight ASC").first
      role = user_role.role rescue user_role

      if role.to_s.downcase.squish == 'student'
        student = Student.find_by_username(params['username'])
        session[:current_student_id] = student.student_id
        session[:current_user_role] = 'student'
        redirect_to("/student/students_page") and return
      end

      if role.to_s.downcase.squish == 'guardian'
        parent = Parent.find_by_username(params['username'])
        session[:current_guardian_id] = parent.parent_id
        session[:current_user_role] = 'guardian'
        redirect_to("/parent/guardians_page") and return
      end

      redirect_to("/") and return
    else
      flash[:error] = "Invalid username or password"
      redirect_to :controller => "user", :action => "login" and return
    end
  end
  
  def user_management_menu
    @users = User.find(:all)
  end

  def user_management_dashboard
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

  def new_user
    @users = User.find(:all)
    
  end

  def edit_user
    if (params[:user_id])
      @user = User.find(params[:user_id])
    end
    @users = User.find(:all)
    
  end

  def void_users
    @users = User.find(:all)
    
  end

  def view_users
    @users = User.find(:all)
    
  end
  
  def create
    first_name = params[:first_name]
    last_name = params[:last_name]
    password = params[:password]
    password_confirm = params[:password_confirm]
    errors = ""
    user_exists = User.find_by_username(params[:username])
    errors += 'Username already exists.' if user_exists
    errors += ' Password mismatch.' if (password != password_confirm)
    
    unless (errors.blank?)
      flash[:error] = "#{errors}"
      redirect_to :controller => "user", :action => "new_user" and return
    end
    
    user = User.create({
        :first_name => first_name,
        :last_name => last_name,
        :password => password,
        :username => params[:username]
      })
    if user
      flash[:notice] = "Operation successful"
      redirect_to :controller => "user", :action => "new_user" and return
    end
  end

  def update_user_data
    if params[:user_id].blank?
      flash[:error] = "You didn't select any user to edit. Select user first"
      redirect_to :controller => "user", :action => "edit_user" and return
    end
    user = User.find(params[:user_id])
    first_name = params[:first_name]
    last_name = params[:last_name]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password != password_confirm)
      flash[:error] = "Password mismatch."
      redirect_to :controller => "user", :action => "edit_user", :user_id => params[:user_id] and return
    end
    if (user.update_attributes({
            :first_name => first_name,
            :last_name => last_name,
            :username => params[:username],
            :password => params[:password]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "user", :action => "edit_user" and return
    else
      flash[:error] = "Oops. Something wen't wrong. That's what we know"
      redirect_to :controller => "user", :action => "edit_user" and return
    end
  end

  def delete_users
    if (params[:mode] == 'single_entry')
      user = User.find(params[:user_id])
      user.delete
      render :text => "true" and return
    end

    user_ids = params[:user_ids].split(",")
    (user_ids || []).each do |user_id|
      user = User.find(user_id)
      user.delete
    end

    render :text => "true" and return
  end

  def user_account_settings_menu
    @user = User.find(session[:current_user_id])
    render :layout => "students" if session[:current_user_role] == 'student'
    render :layout => "guardians" if session[:current_user_role] == 'guardian'
  end

  def switch_role

    role = params[:role]
    role_link_mapping = {}
    role_link_mapping["student"] = "/student/students_page"
    role_link_mapping["guardian"] = "/parent/guardians_page"
    role_link_mapping["admin"] = "/"
    
    username = User.find(session[:current_user_id]).username
    if role == 'student'
      student = Student.find_by_username(username) rescue nil
      if student.blank?
        flash[:error] = "Oops. Something went wrong. Unable to find your student account"
        redirect_to(request.referrer) and return
      end
      session.delete(:current_guardian_id)
      session[:current_student_id] = student.student_id
      session[:current_user_role] = 'student'
    end

    if role == 'guardian'
      parent = Parent.find_by_username(username) rescue nil
      if parent.blank?
        flash[:error] = "Oops. Something went wrong. Unable to find your guardian account"
        redirect_to(request.referrer) and return
      end
      session.delete(:current_student_id)
      session[:current_guardian_id] = parent.parent_id
      session[:current_user_role] = 'guardian'
    end

    session.delete(:current_user_role)
    session[:current_user_role] = role
    redirect_to("#{role_link_mapping[role]}") and return
  end
  
  def update_account
    @user = User.find(session[:current_user_id])
    
    if params[:edit_mode] == 'username'
      user = User.find_by_username(params[:username])
      unless user.blank?
        unless (user.id == @user.id)
          flash[:error] = "Unable to save. Username is already in use."
          redirect_to :controller => "user", :action => "user_account_settings_menu", :edit_mode => "username" and return
        end
      end
      if @user.update_attributes({
            :username => params[:username]
          })
        flash[:notice] = "Operation successful"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      end
    end
    
    if params[:edit_mode] == 'password'
      if (User.authenticate(@user.username, params[:password]))
        if (params[:new_password] == params[:repeat_password])
          @user.password = params[:new_password]
          @user.save
          flash[:notice] = "Operation successful"
          redirect_to :controller => "user", :action => "user_account_settings_menu" and return
        else
          flash[:error] = "Unable to save. New Password and Repeat password mismatch"
          redirect_to :controller => "user", :action => "user_account_settings_menu" and return
        end
      else
        flash[:error] = "Unable to save. Old password is not correct"
        redirect_to :controller => "user", :action => "/user_account_settings_menu", :edit_mode => "password" and return
      end
    end

    if params[:edit_mode] == 'first_name'
      if @user.update_attributes({
            :first_name => params[:first_name]
          })
        flash[:notice] = "Operation successful"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      else
        flash[:error] = "Unable to save. Check for erros and try again"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      end
    end

    if params[:edit_mode] == 'last_name'
      if @user.update_attributes({
            :last_name => params[:last_name]
          })
        flash[:notice] = "Operation successful"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      else
        flash[:error] = "Unable to save. Check for erros and try again"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      end
    end
    
    if params[:edit_mode] == 'names'
      if @user.update_attributes({
            :first_name => params[:first_name],
            :last_name => params[:last_name]
          })
        flash[:notice] = "Operation successful"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      else
        flash[:error] = "Unable to save. Check for erros and try again"
        redirect_to :controller => "user", :action => "user_account_settings_menu" and return
      end
    end
  end
end
