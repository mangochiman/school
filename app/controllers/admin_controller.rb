class AdminController < ApplicationController
  def home
    render :layout => "application"
  end

  def page_full_width
     render :layout => false
  end
  
  def page_other
     render :layout => false
  end

  def dashboard
   render :layout => false
  end

  def settings
       
  end
end
