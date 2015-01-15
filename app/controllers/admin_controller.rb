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
          @settings = school_setting
          render :layout => false
  end

  def index
    render :layout => false
  end

  def time_table
    render :layout => false
  end

  def research
    render :layout => false
  end

  def add_property
      g = GlobalProperty.find_by_property("#{params[:name]}")
      if g.blank?
        GlobalProperty.create(:property => params[:name],
                                  :value => params[:value])
      else
        g.value = params[:value]
        g.save
      end
        render :text => g.to_json
  end
  
  def semester_settings
    render :layout => false
  end

  def set_total_semesters
     render :layout => false
  end

  def set_current_semester
    render :layout => false
  end

  def view_semesters
    render :layout => false
  end
end
