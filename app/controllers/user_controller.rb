class UserController < ApplicationController

  def login
    @school_name = GlobalProperty.find_by_property("school_name") rescue nil
    if request.get?
      reset_session
    else
      raise params['username'].to_yaml
      user = User.find_by_username(params['username'])
      logged_in_user = user.try_to_login(params['password'])
      if not logged_in_user.blank?
        reset_session
        session[:current_user_id] = user.id
        redirect_to("/")
      else
        flash[:error] = "Invalid username or password"
      end
    end
    @settings = school_setting
    render :layout => false
  end

  def user_management_menu
    render :layout => false
  end

  def user_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def new_user
    @users = User.find(:all)
    render :layout => false
  end

  def edit_user
    if (params[:user_id])
      @user = User.find(params[:user_id])
    end
    @users = User.find(:all)
    render :layout => false
  end
  
  def create
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
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password != password_confirm)
      flash[:error] = "Password mismatch."
      redirect_to :controller => "user", :action => "edit_user", :user_id => params[:user_id] and return
    end
    if (user.update_attributes({
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
end
