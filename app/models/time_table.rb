require "composite_primary_keys"

class TimeTable < ActiveRecord::Base
  set_table_name :time_table
  set_primary_keys :teacher_id, :class_room_id, :course_id, :date, :time

  belongs_to :teacher
  belongs_to :class_room
  belongs_to :course

  def self.class_periods
    period_start_time = GlobalProperty.find_by_property("period_start_time").value
    period_end_time = GlobalProperty.find_by_property("period_end_time").value
    period_length = GlobalProperty.find_by_property("period_length").value.to_i

    lunch_start_time = GlobalProperty.find_by_property("lunch_start_time").value
    lunch_period_length = GlobalProperty.find_by_property("lunch_period_length").value.to_i

    period_start_time_parsed = Time.parse(period_start_time)
    period_end_time_parsed = Time.parse(period_end_time)
    lunch_start_time_parsed = Time.parse(lunch_start_time)
    lunch_end_time_parsed = lunch_start_time_parsed + lunch_period_length.minutes
    class_periods = []

    while (period_start_time_parsed <= lunch_start_time_parsed)
      formatted_time = period_start_time_parsed.strftime("%H:%M")
      class_periods << formatted_time
      period_start_time_parsed += period_length.minutes
    end
    
    while (lunch_end_time_parsed <= period_end_time_parsed)
      formatted_time = lunch_end_time_parsed.strftime("%H:%M")
      class_periods << formatted_time
      lunch_end_time_parsed += period_length.minutes
    end

    last_period = class_periods.last
    last_period_parsed = Time.parse(last_period)

    if ((last_period_parsed + period_length.minutes) > period_end_time_parsed) #last period is exceeding last period time set
      i = 0
      class_periods_modified = []
      while (i <= class_periods.length - 2)
        class_periods_modified << class_periods[i]
        i = i + 1
      end
      return class_periods_modified
    end
    
    return class_periods
  end

  def self.course_settings
    course_settings_hash = {}
    
    min_periods_per_week = GlobalProperty.find_by_property("min_periods_per_week").value.to_i
    max_periods_per_week = GlobalProperty.find_by_property("max_periods_per_week").value.to_i
    recommended_periods_per_week = GlobalProperty.find_by_property("recommended_periods_per_week").value.to_i
    
    course_settings_hash["min_periods_per_week"] = min_periods_per_week
    course_settings_hash["max_periods_per_week"] = max_periods_per_week
    course_settings_hash["recommended_periods_per_week"] = recommended_periods_per_week
    return course_settings_hash
  end

  def self.teacher_settings
    teacher_settings_hash = {}
    teacher_min_periods_per_week = GlobalProperty.find_by_property("teacher_min_periods_per_week").value.to_i
    teacher_max_periods_per_week = GlobalProperty.find_by_property("teacher_max_periods_per_week").value.to_i
    teacher_recommended_periods_per_week = GlobalProperty.find_by_property("teacher_recommended_periods_per_week").value.to_i
    teacher_max_courses_per_row = GlobalProperty.find_by_property("teacher_max_courses_per_row").value.to_i
    teacher_min_courses_per_day = GlobalProperty.find_by_property("teacher_min_courses_per_day").value.to_i
    teacher_max_courses_per_day = GlobalProperty.find_by_property("teacher_max_courses_per_day").value.to_i

    teacher_settings_hash["teacher_min_periods_per_week"] = teacher_min_periods_per_week
    teacher_settings_hash["teacher_max_periods_per_week"] = teacher_max_periods_per_week
    teacher_settings_hash["teacher_recommended_periods_per_week"] = teacher_recommended_periods_per_week
    teacher_settings_hash["teacher_max_courses_per_row"] = teacher_max_courses_per_row
    teacher_settings_hash["teacher_min_courses_per_day"] = teacher_min_courses_per_day
    teacher_settings_hash["teacher_max_courses_per_day"] = teacher_max_courses_per_day
    
    return teacher_settings_hash
  end
  
end
