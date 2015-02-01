class UserController < ApplicationController

  def login
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
end
