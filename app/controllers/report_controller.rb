class ReportController < ApplicationController
  def index
    render :layout => false
  end

  def students_per_semester_report
    render :layout => false
  end

  def students_per_year_report
    render :layout => false
  end

  def students_per_class_report
    render :layout => false
  end

  def courses_report
    render :layout => false
  end
  
  def courses_per_class_report
    render :layout => false
  end

  def teachers_report
    render :layout => false
  end

  def teachers_per_subjects_report
    render :layout => false
  end

  def results_per_class_report
    render :layout => false
  end

  def subject_pass_rate_report
    render :layout => false
  end

  def employees_report
    render :layout => false
  end
end
