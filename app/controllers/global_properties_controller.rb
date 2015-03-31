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
end
