class SemestersController < ApplicationController
  def index
    @current_year = Date.today.year
    @current_semester = GlobalProperty.find_by_property("current_semester").value rescue nil
    @current_semester_start_date = GlobalProperty.find_by_property("current_semester_start_date").value rescue nil
    @current_semester_end_date = GlobalProperty.find_by_property("current_semester_end_date").value rescue nil
    render :layout => false
  end

  def semester_settings
    @total_semesters = Semester.all.count
    render :layout => false
  end

  def set_total_semesters
     render :layout => false
  end

  def set_current_semester
    @total_semesters = Semester.all.count
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
        
        GlobalProperty.create({:property => "current_semester", :value => current_semester})
        GlobalProperty.create({:property => "current_semester_start_date",:value => current_semester_start_date})
        GlobalProperty.create({:property => "current_semester_end_date",:value => current_semester_end_date})
      end

      flash[:notice] = "Operation successful"
      redirect_to :action => "index" and return
    end
    render :layout => false
  end

  def view_semesters
    render :layout => false
  end

  def create_semester
    total_semesters = params[:total_semesters].to_i

    ActiveRecord::Base.transaction do
      Semester.delete_all
      (1..total_semesters).each do |semester|
        Semester.create({
          :semester_number => semester
        })
      end
    end
    
    flash[:notice] = "Operation successful"
    redirect_to :action => "index" and return
  end

end
