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
    
    if (request.method == :post)
      class_room_id = params[:class_room]
      semester_id = params[:semester]
      
      if (semester_id.match(/ALL/i))
        semester_id = Semester.all.collect{|s|s.id}.join(', ')
      end
      
      hash = {}
      unless (params[:year].match(/ALL/i))
        unless (params[:class_room].match(/ALL/i))
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
            s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
            WHERE cr.year = #{params[:year]} AND crs.class_room_id=#{class_room_id} AND
            crs.semester_id IN (#{semester_id})")

          hash[params[:year]] = {}
          hash[params[:year]][params[:class_room]] = {}
          students.each do |student|
            student_id  = student.id
            student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
            hash[params[:year]][params[:class_room]][student_id] = {}
            hash[params[:year]][params[:class_room]][student_id]["name"] = student_name
            hash[params[:year]][params[:class_room]][student_id]["dob"] = student.dob
            hash[params[:year]][params[:class_room]][student_id]["email"] = student.email
            hash[params[:year]][params[:class_room]][student_id]["gender"] = student.gender
            hash[params[:year]][params[:class_room]][student_id]["class_room"] = student.name #class room name
          end
          
          hash[params[:year]].delete(params[:class_room]) if hash[params[:year]][params[:class_room]].blank?
        else
          hash[params[:year]] = {}
          class_room_ids = ClassRoom.all.map(&:id)
          class_room_ids.each do |class_id|
            hash[params[:year]][class_id] = {}
            students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
            s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
            WHERE cr.year = #{params[:year]} AND crs.class_room_id=#{class_id} AND
            crs.semester_id IN (#{semester_id})")

            students.each do |student|
              student_id  = student.id
              student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
              hash[params[:year]][class_id][student_id] = {}
              hash[params[:year]][class_id][student_id]["name"] = student_name
              hash[params[:year]][class_id][student_id]["dob"] = student.dob
              hash[params[:year]][class_id][student_id]["email"] = student.email
              hash[params[:year]][class_id][student_id]["gender"] = student.gender
              hash[params[:year]][class_id][student_id]["class_room"] = student.name #class room name
            end

            hash[params[:year]].delete(class_id) if hash[params[:year]][class_id].blank?
          end
        end
      else
        hash = {}
        (start_year..end_year).to_a.each do |year|
          unless (params[:class_room].match(/ALL/i))
            students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
            s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
            WHERE cr.year = #{year} AND crs.class_room_id=#{class_room_id} AND
            crs.semester_id IN (#{semester_id})")

            hash[year] = {}
            hash[year][params[:class_room]] = {}
            students.each do |student|
              student_id  = student.id
              student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
              hash[year][params[:class_room]][student_id] = {}
              hash[year][params[:class_room]][student_id]["name"] = student_name
              hash[year][params[:class_room]][student_id]["dob"] = student.dob
              hash[year][params[:class_room]][student_id]["email"] = student.email
              hash[year][params[:class_room]][student_id]["gender"] = student.gender
              hash[year][params[:class_room]][student_id]["class_room"] = student.name #class room name
            end
            hash[year].delete(params[:class_room]) if hash[year][params[:class_room]].blank?
          else
            hash[year] = {}
            class_room_ids = ClassRoom.all.map(&:id)
            class_room_ids.each do |class_id|
              hash[year][class_id] = {}
              students = Student.find_by_sql("SELECT * FROM student s INNER JOIN class_room_student crs ON
              s.student_id = crs.student_id INNER JOIN class_room cr ON crs.class_room_id = cr.class_room_id
              WHERE cr.year = #{year} AND crs.class_room_id=#{class_id} AND
              crs.semester_id IN (#{semester_id})")

              students.each do |student|
                student_id  = student.id
                student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
                hash[year][class_id][student_id] = {}
                hash[year][class_id][student_id]["name"] = student_name
                hash[year][class_id][student_id]["dob"] = student.dob
                hash[year][class_id][student_id]["email"] = student.email
                hash[year][class_id][student_id]["gender"] = student.gender
                hash[year][class_id][student_id]["class_room"] = student.name #class room name
              end
              hash[year].delete(class_id) if hash[year][class_id].blank?
            end
          end
        end
      end
      
      render :text => hash.to_json and return
    end

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

    if (request.method == :post)
      year = params[:year]
      if (year.match(/ALL/i))
        year = (start_year..end_year).to_a.join(', ')
      end
      courses = Course.find_by_sql("SELECT * FROM course WHERE DATE_FORMAT(created_at, '%Y') IN (#{year})")
      hash = {}

      (courses || []).each do |course|
        course_id = course.course_id
        hash[course_id] = {}
        hash[course_id]["course_name"] = course.name
        hash[course_id]["date_created"] = course.created_at.strftime("%d-%b-%Y")
      end
      
      render :text => hash.to_json and return
    end
    
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
    
    if (request.method == :post)
      class_room_id = params[:class_room]
      semester_id = params[:semester]

      if (semester_id.match(/ALL/i))
        semester_id = Semester.all.collect{|s|s.id}.join(', ')
      end

      hash = {}
      unless (params[:year].match(/ALL/i))
        unless (params[:class_room].match(/ALL/i))
          courses = Course.find_by_sql("SELECT c.course_id, c.name, c.created_at FROM course c INNER JOIN class_room_course crc ON
            c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.class_room_id
            INNER JOIN class_room_student crs ON crs.class_room_id=cr.class_room_id
            WHERE cr.year = #{params[:year]} AND crc.class_room_id=#{class_room_id} AND
            crs.semester_id IN (#{semester_id})")

          hash[params[:year]] = {}
          hash[params[:year]][params[:class_room]] = {}
          courses.each do |course|
            course_id  = course.course_id
            course_name = course.name
            date_created = course.created_at.strftime("%d-%b-%Y")
            hash[params[:year]][params[:class_room]][course_id] = {}
            hash[params[:year]][params[:class_room]][course_id]["course_name"] = course_name
            hash[params[:year]][params[:class_room]][course_id]["date_created"] = date_created
          end

          hash[params[:year]].delete(params[:class_room]) if hash[params[:year]][params[:class_room]].blank?
        else
          hash[params[:year]] = {}
          class_room_ids = ClassRoom.all.map(&:id)
          class_room_ids.each do |class_id|
            hash[params[:year]][class_id] = {}
            
            courses = Course.find_by_sql("SELECT c.course_id, c.name, c.created_at FROM course c INNER JOIN class_room_course crc ON
            c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.
            INNER JOIN class_room_student crs ON crs.class_room_id=cr.class_room_id
            WHERE cr.year = #{params[:year]} AND crc.class_room_id=#{class_id} AND
            crs.semester_id IN (#{semester_id})")

            courses.each do |course|
              course_id  = course.course_id
              course_name = course.name
              date_created = course.created_at.strftime("%d-%b-%Y")

              hash[params[:year]][class_id][course_id] = {}
              hash[params[:year]][class_id][course_id]["course_name"] = course_name
              hash[params[:year]][class_id][course_id]["date_created"] = date_created
            end

            hash[params[:year]].delete(class_id) if hash[params[:year]][class_id].blank?
          end
        end
      else
        hash = {}
        (start_year..end_year).to_a.each do |year|
          unless (params[:class_room].match(/ALL/i))

            courses = Course.find_by_sql("SELECT c.course_id, c.name, c.created_at FROM course c INNER JOIN class_room_course crc ON
            c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.class_room_id
            INNER JOIN class_room_student crs ON crs.class_room_id=cr.class_room_id
            WHERE cr.year = #{year} AND crc.class_room_id=#{class_room_id} AND
            crs.semester_id IN (#{semester_id})")
            
            hash[year] = {}
            hash[year][params[:class_room]] = {}
            courses.each do |course|

              course_id  = course.course_id
              course_name = course.name
              date_created = course.created_at.strftime("%d-%b-%Y")

              hash[year][params[:class_room]][course_id] = {}
              hash[year][params[:class_room]][course_id]["course_name"] = course_name
              hash[year][params[:class_room]][course_id]["date_created"] = date_created
            end
            hash[year].delete(params[:class_room]) if hash[year][params[:class_room]].blank?
          else
            hash[year] = {}
            class_room_ids = ClassRoom.all.map(&:id)
            class_room_ids.each do |class_id|
              hash[year][class_id] = {}
              courses = Course.find_by_sql("SELECT c.course_id, c.name, c.created_at FROM course c INNER JOIN class_room_course crc ON
              c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.class_room_id
              INNER JOIN class_room_student crs ON crs.class_room_id=cr.class_room_id
              WHERE cr.year = #{year} AND crc.class_room_id=#{class_id} AND
              crs.semester_id IN (#{semester_id})")

              courses.each do |course|

                course_id  = course.course_id
                course_name = course.name
                date_created = course.created_at.strftime("%d-%b-%Y")

                hash[year][class_id][course_id] = {}
                hash[year][class_id][course_id]["course_name"] = course_name
                hash[year][class_id][course_id]["date_created"] = date_created
              end
            
              hash[year].delete(class_id) if hash[year][class_id].blank?
            end
          end
        end
      end

      render :text => hash.to_json and return
    end

    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end
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
