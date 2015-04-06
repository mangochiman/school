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
end
