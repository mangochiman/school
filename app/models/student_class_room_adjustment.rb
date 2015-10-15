class StudentClassRoomAdjustment < ActiveRecord::Base
  set_table_name :student_class_room_adjustment
	set_primary_key :adjustment_id

  belongs_to :student
  belongs_to :teacher
  belongs_to :semester
  belongs_to :class_room, :foreign_key => :new_class_room_id

  before_save :add_dates

  def add_dates
    start_date = GlobalProperty.find_by_property("current_semester_start_date").value
    end_date = GlobalProperty.find_by_property("current_semester_end_date").value
    semester = GlobalProperty.find_by_property("current_semester").value
    
    self.semester_id = semester
    self.start_date = start_date
    self.end_date = end_date
  end
end
