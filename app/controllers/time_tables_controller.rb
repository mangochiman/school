class TimeTablesController < ApplicationController
  def generate_roster
    teacher = Teacher.find(2)#TODO later
    class_room_teachers = teacher.class_room_teachers
    start_date = '06/April/2015'.to_date
    end_date = '10/April/2015'.to_date
    class_room_teachers.each do |class_room_teacher|
      
    end
  end
end
