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

  def access_denied
    #flash[:error] = 'Oops. You need to login before you can view that page.'
    redirect_to ("/user/login") and return
  end
 
end
