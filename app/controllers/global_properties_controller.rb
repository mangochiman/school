class GlobalPropertiesController < ApplicationController

  def create_period_properties
    ActiveRecord::Base.transaction do
      period_start_time = GlobalProperty.find_or_create_by_property("period_start_time")
      period_start_time.value = params[:period_start_time]
      period_start_time.save

      period_end_time = GlobalProperty.find_or_create_by_property("period_end_time")
      period_end_time.value = params[:period_end_time]
      period_end_time.save

      period_length = GlobalProperty.find_or_create_by_property("period_length")
      period_length.value = params[:period_length]
      period_length.save

      lunch_start_time = GlobalProperty.find_or_create_by_property("lunch_start_time")
      lunch_start_time.value = params[:lunch_start_time]
      lunch_start_time.save

      lunch_period_length = GlobalProperty.find_or_create_by_property("lunch_period_length")
      lunch_period_length.value = params[:lunch_period_length]
      lunch_period_length.save
    end

    flash[:notice] = "Operation successful"
    redirect_to :controller => "admin", :action => "period_settings" and return
  end

  def create_course_settings
    ActiveRecord::Base.transaction do
      min_periods_per_week = GlobalProperty.find_or_create_by_property("min_periods_per_week")
      min_periods_per_week.value = params[:min_periods_per_week]
      min_periods_per_week.save

      max_periods_per_week = GlobalProperty.find_or_create_by_property("max_periods_per_week")
      max_periods_per_week.value = params[:max_periods_per_week]
      max_periods_per_week.save

      recommended_periods_per_week = GlobalProperty.find_or_create_by_property("recommended_periods_per_week")
      recommended_periods_per_week.value = params[:recommended_periods_per_week]
      recommended_periods_per_week.save
    end
    flash[:notice] = "Operation successful"
    redirect_to :controller => "admin", :action => "course_settings" and return
  end

  def create_teacher_settings
    ActiveRecord::Base.transaction do
      teacher_min_periods_per_week = GlobalProperty.find_or_create_by_property("teacher_min_periods_per_week")
      teacher_min_periods_per_week.value = params[:teacher_min_periods_per_week]
      teacher_min_periods_per_week.save

      teacher_max_periods_per_week = GlobalProperty.find_or_create_by_property("teacher_max_periods_per_week")
      teacher_max_periods_per_week.value = params[:teacher_max_periods_per_week]
      teacher_max_periods_per_week.save

      teacher_recommended_periods_per_week = GlobalProperty.find_or_create_by_property("teacher_recommended_periods_per_week")
      teacher_recommended_periods_per_week.value = params[:teacher_recommended_periods_per_week]
      teacher_recommended_periods_per_week.save

      teacher_max_courses_per_row = GlobalProperty.find_or_create_by_property("teacher_max_courses_per_row")
      teacher_max_courses_per_row.value = params[:teacher_max_courses_per_row]
      teacher_max_courses_per_row.save

      teacher_min_courses_per_day = GlobalProperty.find_or_create_by_property("teacher_min_courses_per_day")
      teacher_min_courses_per_day.value = params[:teacher_min_courses_per_day]
      teacher_min_courses_per_day.save

      teacher_max_courses_per_day = GlobalProperty.find_or_create_by_property("teacher_max_courses_per_day")
      teacher_max_courses_per_day.value = params[:teacher_max_courses_per_day]
      teacher_max_courses_per_day.save
    end
    flash[:notice] = "Operation successful"
    redirect_to :controller => "admin", :action => "teacher_settings" and return
  end
  
end
