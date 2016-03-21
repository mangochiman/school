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
  
  protected

  def authenticate_user
    user = User.find(session[:current_user_id]) rescue nil
    return true unless user.blank?
    access_denied
    return false
  end

  def check_student_role
    user = User.find(session[:current_user_id]) rescue nil
    unless user.blank?
      user_roles = user.user_roles.collect{|r|r.role}
      return true if user_roles.include?('student')
      flash[:error] = "An attempt to bypass security was noted. Login with the student account to continue"
      access_denied
      return false
    end
  end

  def check_guardian_role
    user = User.find(session[:current_user_id]) rescue nil
    unless user.blank?
      user_roles = user.user_roles.collect{|r|r.role}
      return true if user_roles.include?('guardian')
      flash[:error] = "An attempt to bypass security was noted. Login with the guardian account to continue"
      access_denied
      return false
    end
  end

  def check_admin_role
    user = User.find(session[:current_user_id]) rescue nil
    unless user.blank?
      user_roles = user.user_roles.collect{|r|r.role}
      return true if user_roles.include?('admin')
      flash[:error] = "An attempt to bypass security was noted. Login with the admin account to continue"
      access_denied
      return false
    end
  end

  def access_denied
    #flash[:error] = 'Oops. You need to login before you can view that page.'
    redirect_to ("/user/login") and return
  end
 
end
