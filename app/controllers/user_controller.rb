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
  
end
