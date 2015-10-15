class ReportController < ApplicationController
  def index
    
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
        students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id
          WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]} AND scra.semester_id IN (#{semester_id})")

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
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year} AND scra.semester_id IN (#{semester_id})")
          
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
    
  end

  def students_per_year_report
    start_year = Date.today.year - 5
    end_year = Date.today.year

    if (request.method == :post)
      hash = {}
      unless (params[:year].match(/ALL/i))
        students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]}
          GROUP BY s.student_id, DATE_FORMAT(scra.start_date, '%Y')")

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
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year}
          GROUP BY s.student_id, DATE_FORMAT(scra.start_date, '%Y')")

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
          students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
            s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]} AND
            scra.new_class_room_id=#{class_room_id} AND scra.semester_id IN (#{semester_id})")

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
            students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
            s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]} AND
            scra.new_class_room_id=#{class_id} AND scra.semester_id IN (#{semester_id})")

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
            students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
            s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year} AND
            scra.new_class_room_id=#{class_room_id} AND scra.semester_id IN (#{semester_id})")

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
              students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
              s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year} AND scra.new_class_room_id=#{class_id} AND
              scra.semester_id IN (#{semester_id})")

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
    
  end
  
  def courses_per_class_report
    start_year = Date.today.year - 5
    end_year = Date.today.year
=begin
students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]}
          GROUP BY s.student_id, DATE_FORMAT(scra.start_date, '%Y')")
=end
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
            INNER JOIN student_class_room_adjustment scra ON scra.new_class_room_id = cr.class_room_id
            WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]} AND scra.new_class_room_id = #{class_room_id} AND
            scra.semester_id IN (#{semester_id})")

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
            c.course_id = crc.course_id INNER JOIN class_room cr ON crc.class_room_id = cr.class_room_id
            INNER JOIN student_class_room_adjustment scra ON scra.new_class_room_id = cr.class_room_id
            WHERE DATE_FORMAT(scra.start_date, '%Y') = #{params[:year]} AND scra.new_class_room_id = #{class_id} AND
            scra.semester_id IN (#{semester_id})")

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
            INNER JOIN student_class_room_adjustment scra ON scra.new_class_room_id = cr.class_room_id
            WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year} AND scra.new_class_room_id = #{class_room_id} AND
            scra.semester_id IN (#{semester_id})")
            
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
              INNER JOIN student_class_room_adjustment scra ON scra.new_class_room_id = cr.class_room_id
              WHERE DATE_FORMAT(scra.start_date, '%Y') = #{year} AND scra.new_class_room_id = #{class_id} AND
              scra.semester_id IN (#{semester_id})")

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
    
  end

  def teachers_report
    if (request.method == :post)
      start_date = params[:start_date]
      end_date = params[:end_date]
      teachers = Teacher.find(:all, :conditions => ["DATE(created_at) >= ? AND DATE(created_at) <= ?",
          start_date.to_date, end_date.to_date])
      hash = {}
      (teachers || []).each do |teacher|
        teacher_id = teacher.teacher_id
        teacher_name = teacher.fname.capitalize.to_s + ' ' + teacher.lname.capitalize.to_s
        hash[teacher_id] = {}
        hash[teacher_id]["name"] = teacher_name
        hash[teacher_id]["dob"] = teacher.dob
        hash[teacher_id]["email"] = teacher.email
        hash[teacher_id]["gender"] = teacher.gender
      end
      render :text => hash.to_json and return
    end
    
  end

  def teachers_per_subjects_report
    if (request.method == :post)
      hash = {}
      class_rooms = ClassRoom.all
      if (params[:teacher_id].match(/ALL/i))
        teachers = Teacher.all
        teachers.each do |teacher|
          teacher_id = teacher.teacher_id
          hash[teacher_id] = {}
          class_rooms.each do |class_room|
            class_room_id = class_room.class_room_id
            hash[teacher_id][class_room_id] = {}
            courses = []

            teacher_class_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", teacher.teacher_id, class_room.class_room_id])

            (teacher_class_courses || []).each do |tcc|
              courses << tcc.course.name
            end

            count = 0
            row_hash = {}
            courses.in_groups_of(5).each do |group|
              count = count + 1
              row_hash[count] = group.compact
            end

            hash[teacher_id][class_room_id]["courses"] = row_hash unless courses.blank?
            hash[teacher_id].delete(class_room_id) if hash[teacher_id][class_room_id].blank?
          end
        end
      else
        teacher_id = params[:teacher_id]
        hash[teacher_id] = {}
        class_rooms.each do |class_room|
          class_room_id = class_room.class_room_id
          hash[teacher_id][class_room_id] = {}
          courses = []

          teacher_class_courses = TeacherClassRoomCourse.find(:all, :conditions => ["teacher_id =? AND
              class_room_id =?", teacher_id, class_room.class_room_id])

          (teacher_class_courses || []).each do |tcc|
            courses << tcc.course.name
          end
          count = 0
          row_hash = {}
          courses.in_groups_of(5).each do |group|
            count = count + 1
            row_hash[count] = group.compact
          end

          hash[teacher_id][class_room_id]["courses"] = row_hash unless courses.blank?
          hash[teacher_id].delete(class_room_id) if hash[teacher_id][class_room_id].blank?
        end
      end
      render :text => hash.to_json and return
    end
    @teachers = ["All"]
    @teachers += Teacher.all.collect{|t|
      name = t.fname.to_s.capitalize + ' ' + t.lname.to_s.capitalize + ' (' + (t.gender.first.capitalize rescue '?') + ')'
      [name, t.teacher_id]
    }

    @courses = ["All"]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}

    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end
    
    @teachers_hash = {}
    Teacher.all.each do |t|
      name = t.fname.to_s.capitalize + ' ' + t.lname.to_s.capitalize + ' (' + (t.gender.first.capitalize rescue '?') + ')'
      teacher_id = t.teacher_id
      @teachers_hash[teacher_id] = name
    end
    
    
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
    
  end

  def subject_pass_rate_report
    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @courses = ["All"]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}
    
  end

  def employees_report
    
  end

  def reports_generator_menu
    
  end

  def reports_generator_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end
end
