class SemestersController < ApplicationController
  def index
    render :layout => false
  end

  def semester_settings
    render :layout => false
  end

  def set_total_semesters
     render :layout => false
  end

  def set_current_semester
    if (request.method == :post)
      current_semester = params[:semester]
      current_semester_start_date = params[:start_date]
      current_semester_end_date = params[:end_date]

      ActiveRecord::Base.transaction do
        cs = GlobalProperty.find_by_property("current_semester")
        cs.delete unless cs.blank?

        cssd = GlobalProperty.find_by_property("current_semester_start_date")
        cssd.delete unless cssd.blank?

        csed = GlobalProperty.find_by_property("current_semester_end_date")
        csed.delete unless csed.blank?
        
        GlobalProperty.create(
             {
              :property => "current_semester",
              :value => current_semester
             },
             {
              :property => "current_semester_start_date",
              :value => current_semester_start_date
             },
             {
              :property => "current_semester_end_date",
              :value => current_semester_end_date
             }
        )
      end

      redirect_to :action => "index" and return
    end
    render :layout => false
  end

  def view_semesters
    render :layout => false
  end
  
end
