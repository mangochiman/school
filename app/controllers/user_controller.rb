class UserController < ApplicationController

  def login
    @settings = school_setting
    render :layout => false
  end
end
