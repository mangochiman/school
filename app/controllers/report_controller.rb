class ReportController < ApplicationController
  def index
    render :layout => false
  end

  def students_per_semester_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    render :layout => false
  end

  def students_per_year_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    render :layout => false
  end

  def students_per_class_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    render :layout => false
  end

  def courses_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    render :layout => false
  end
  
  def courses_per_class_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
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
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @courses = ["All"]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}
    render :layout => false
  end

  def employees_report
    render :layout => false
  end
end
