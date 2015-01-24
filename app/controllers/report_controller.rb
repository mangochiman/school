class ReportController < ApplicationController
  def index
    render :layout => false
  end

  def students_per_semester_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    
    if (request.method == :post)
      semester_id = params[:semester_id]
      if (semester_id.match(/ALL/i))
        semester_id = Semester.all.collect{|s|s.id}.join(', ')
      end
      hash = {}
      unless (params[:year].match(/ALL/i))
        students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
          s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
          WHERE cr.year = #{params[:year]} AND crs.semester_id IN (#{semester_id})")

        hash[params[:year]] = {}
        students.each do |student|
          student_id  = student.id
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[params[:year]][student_id] = {}
          hash[params[:year]][student_id]["name"] = student_name
          hash[params[:year]][student_id]["dob"] = student.dob
          hash[params[:year]][student_id]["email"] = student.email
          hash[params[:year]][student_id]["gender"] = student.gender
          hash[params[:year]][student_id]["class_room"] = student.name #class room name
        end
        
        render :text => hash.to_json and return
      else
        hash = {}
        (start_year..end_year).to_a.each do |year|
          hash[year] = {}
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
          s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
          WHERE cr.year = #{year} AND crs.semester_id IN (#{semester_id})")
          
          students.each do |student|
            student_id  = student.id
            student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
            hash[year][student_id] = {}
            hash[year][student_id]["name"] = student_name
            hash[year][student_id]["dob"] = student.dob
            hash[year][student_id]["email"] = student.email
            hash[year][student_id]["gender"] = student.gender
            hash[year][student_id]["class_room"] = student.name #class room name
          end
        end
        
        render :text => hash.to_json and return
      end      
    end

    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    render :layout => false
  end

  def students_per_year_report
    start_year = Date.today.year - 5
    end_year = Date.today.year

    if (request.method == :post)
      hash = {}
      unless (params[:year].match(/ALL/i))
        students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
          s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
          WHERE cr.year = #{params[:year]}")

        hash[params[:year]] = {}
        students.each do |student|
          student_id  = student.id
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[params[:year]][student_id] = {}
          hash[params[:year]][student_id]["name"] = student_name
          hash[params[:year]][student_id]["dob"] = student.dob
          hash[params[:year]][student_id]["email"] = student.email
          hash[params[:year]][student_id]["gender"] = student.gender
          hash[params[:year]][student_id]["class_room"] = student.name #class room name
        end

        render :text => hash.to_json and return
      else
        hash = {}
        (start_year..end_year).to_a.each do |year|
          hash[year] = {}
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
          s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
          WHERE cr.year = #{year}")

          students.each do |student|
            student_id  = student.id
            student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
            hash[year][student_id] = {}
            hash[year][student_id]["name"] = student_name
            hash[year][student_id]["dob"] = student.dob
            hash[year][student_id]["email"] = student.email
            hash[year][student_id]["gender"] = student.gender
            hash[year][student_id]["class_room"] = student.name #class room name
          end
        end

        render :text => hash.to_json and return
      end
    end

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
    @teachers = ["All"]
    @teachers += Teacher.all.collect{|t|
      name = t.fname.to_s.capitalize + ' ' + t.lname.to_s.capitalize + ' (' + t.gender.first.capitalize + ')'
      [name, t.teacher_id]
    }

    @courses = ["All"]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}
    
    render :layout => false
  end

  def results_per_class_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    
    @courses = ["All"]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}
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
