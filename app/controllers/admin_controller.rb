class AdminController < ApplicationController
  def home
    
    render :layout => "application"
  end

  def settings
          render :layout => false
  end
end
