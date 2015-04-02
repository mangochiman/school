require "composite_primary_keys"

class TimeTable < ActiveRecord::Base
  set_table_name :time_table
  set_primary_keys :teacher_id, :class_room_id, :course_id, :date, :time

  belongs_to :teacher
  belongs_to :class_room
  belongs_to :course
end
