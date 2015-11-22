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
          hash[params[:year]][student_id]["class_room"] = student.current_class #class room name
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
            hash[year][student_id]["class_room"] = student.current_class #class room name
          end
        end
        
        render :text => hash.to_json and return
      end      
    end

    @years = ["ALL"]
    @years += (start_year..end_year).to_a.reverse
    @semesters = ["ALL"]
    #@semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}

    semester_audits = SemesterAudit.find(:all)
    @semesters = semester_audits.collect do |semester_audit|
      semester_number = semester_audit.semester.semester_number
      semester_audit_id = semester_audit.semester_id
      start_date = semester_audit.start_date.strftime("%d/%b/%Y") rescue  semester_audit.start_date
      end_date = semester_audit.end_date.strftime("%d/%b/%Y") rescue  semester_audit.end_date
      [semester_audit_id, semester_number, start_date, end_date]
    end
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
          hash[params[:year]][student_id]["class_room"] = student.current_class #class room name
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
            hash[year][student_id]["class_room"] = student.current_class #class room name
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

  def student_payments_report_menu

  end

  def student_performance_report_menu
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @exam_types = [["Select Exam Type", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.exam_type_id]}

    @courses = [["Select Course", ""]]
    @courses += Course.all.collect{|c|[c.name, c.course_id]}

    @years = [["Select Year", ""]]
    @years += (start_year..end_year).to_a.reverse

    @semesters = [["Select Semester", ""]]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end

    if (request.method == :post)
      exam_type = params[:exam_type]
      course = params[:course]
      semester_id = params[:semester]
      year = params[:year]

      class_rooms = ClassRoom.all if params[:class_room].match(/ALL/i)
      class_rooms = [ClassRoom.find(params[:class_room])] unless params[:class_room].match(/ALL/i)

      hash = {}
      
      class_rooms.each do |class_room|
        class_room_id = class_room.class_room_id
        hash[class_room_id] = {}
        students = Student.find_by_sql("SELECT s.*, e.start_date as exam_date, er.marks as grade FROM exam e
          LEFT JOIN exam_result er ON e.exam_id = er.exam_id
          INNER JOIN student_class_room_adjustment scra ON e.class_room_id = scra.new_class_room_id
          INNER JOIN semesters ss ON scra.semester_id = ss.semester_id
          INNER JOIN student s ON scra.student_id = s.student_id
          WHERE e.class_room_id = #{class_room_id} AND e.exam_type_id = #{exam_type} AND e.course_id = #{course}
          AND scra.semester_id = #{semester_id} AND 
          (DATE_FORMAT(ss.start_date, '%Y') = #{year} OR DATE_FORMAT(ss.end_date, '%Y') = #{year})" )

        students.each do |student|
          student_id = student.student_id
          hash[class_room_id][student_id] = {}
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[class_room_id][student_id]["name"] = student_name
          hash[class_room_id][student_id]["dob"] = student.dob
          hash[class_room_id][student_id]["email"] = student.email
          hash[class_room_id][student_id]["gender"] = student.gender
          hash[class_room_id][student_id]["exam_date"] = student.exam_date.to_date.strftime("%d-%b-%Y")
          hash[class_room_id][student_id]["grade"] = student.grade
        end

        hash.delete(class_room_id) if hash[class_room_id].blank?
      end

      render :text => hash.to_json and return
    end
  end

  def students_with_balances
    start_year = Date.today.year - 5
    end_year = Date.today.year

    @payment_types = [["Select Payment Type", ""]]
    @payment_types += PaymentType.all.collect{|p|[p.name, p.payment_type_id]}
    
    @years = [["Select Year", ""]]
    @years += (start_year..end_year).to_a.reverse

    @semesters = [["Select Semester", ""]]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end

    if (request.method == :post)
      payment_type = params[:payment_type]
      semester_id = params[:semester]
      year = params[:year]

      class_rooms = ClassRoom.all if params[:class_room].match(/ALL/i)
      class_rooms = [ClassRoom.find(params[:class_room])] unless params[:class_room].match(/ALL/i)

      hash = {}
      
      class_rooms.each do |class_room|
        class_room_id = class_room.class_room_id
        hash[class_room_id] = {}
        students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE DATE_FORMAT(p.date, '%Y') = #{year} AND scra.new_class_room_id = #{class_room.class_room_id} AND
              p.semester_id = #{semester_id} AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid < amount_required")

        students.each do |student|
          student_id = student.student_id
          total_amount_paid = student.total_amount_paid
          hash[class_room_id][student_id] = {}
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[class_room_id][student_id]["name"] = student_name
          hash[class_room_id][student_id]["dob"] = student.dob
          hash[class_room_id][student_id]["email"] = student.email
          hash[class_room_id][student_id]["gender"] = student.gender
          hash[class_room_id][student_id]["total_amount_paid"] = ActionController::Base.helpers.number_to_currency(total_amount_paid, :unit => 'MK')
        end

        hash.delete(class_room_id) if hash[class_room_id].blank?
      end

      render :text => hash.to_json and return
    end
  end

  def students_without_balances
    start_year = Date.today.year - 5
    end_year = Date.today.year

    @payment_types = [["Select Payment Type", ""]]
    @payment_types += PaymentType.all.collect{|p|[p.name, p.payment_type_id]}

    @years = [["Select Year", ""]]
    @years += (start_year..end_year).to_a.reverse

    @semesters = [["Select Semester", ""]]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end

    if (request.method == :post)
      payment_type = params[:payment_type]
      semester_id = params[:semester]
      year = params[:year]

      class_rooms = ClassRoom.all if params[:class_room].match(/ALL/i)
      class_rooms = [ClassRoom.find(params[:class_room])] unless params[:class_room].match(/ALL/i)

      hash = {}

      class_rooms.each do |class_room|
        class_room_id = class_room.class_room_id
        hash[class_room_id] = {}
        students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE DATE_FORMAT(p.date, '%Y') = #{year} AND scra.new_class_room_id = #{class_room.class_room_id} AND
              p.semester_id = #{semester_id} AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid >= amount_required")

        students.each do |student|
          student_id = student.student_id
          total_amount_paid = student.total_amount_paid
          hash[class_room_id][student_id] = {}
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[class_room_id][student_id]["name"] = student_name
          hash[class_room_id][student_id]["dob"] = student.dob
          hash[class_room_id][student_id]["email"] = student.email
          hash[class_room_id][student_id]["gender"] = student.gender
          hash[class_room_id][student_id]["total_amount_paid"] = ActionController::Base.helpers.number_to_currency(total_amount_paid, :unit => 'MK')
        end

        hash.delete(class_room_id) if hash[class_room_id].blank?
      end

      render :text => hash.to_json and return
    end
    
  end

  def students_who_paid(semester_id, class_room_id, payment_type, year_paid)
    students = Student.find_by_sql("SELECT s.*, SUM(p.amount_paid) as total_amount_paid,
              pt.amount_required as amount_required FROM student s
              INNER JOIN payment p ON s.student_id = p.student_id
              INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
              INNER JOIN payment_type pt ON p.payment_type_id = pt.payment_type_id
              WHERE DATE_FORMAT(p.date, '%Y') = #{year_paid} AND scra.new_class_room_id = #{class_room_id} AND
              p.semester_id = #{semester_id} AND pt.payment_type_id = #{payment_type}
              GROUP BY student_id HAVING total_amount_paid > 0")

    return students.map(&:student_id)
    
  end

  def students_without_payments
    start_year = Date.today.year - 5
    end_year = Date.today.year

    @payment_types = [["Select Payment Type", ""]]
    @payment_types += PaymentType.all.collect{|p|[p.name, p.payment_type_id]}

    @years = [["Select Year", ""]]
    @years += (start_year..end_year).to_a.reverse

    @semesters = [["Select Semester", ""]]
    @semesters += Semester.find(:all).collect{|s|[s.semester_number, s.semester_id]}

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}

    @class_room_hash = {}
    (ClassRoom.all || []).each do |class_room|
      @class_room_hash[class_room.id] = class_room.name
    end

    if (request.method == :post)
      payment_type = params[:payment_type]
      semester_id = params[:semester]
      year = params[:year]

      class_rooms = ClassRoom.all if params[:class_room].match(/ALL/i)
      class_rooms = [ClassRoom.find(params[:class_room])] unless params[:class_room].match(/ALL/i)

      hash = {}

      class_rooms.each do |class_room|
        class_room_id = class_room.class_room_id
        hash[class_room_id] = {}

        students_who_paid_ids = students_who_paid(semester_id, class_room_id, payment_type, year).join(', ')
        students_who_paid_ids = '0' if students_who_paid_ids.blank?
        
        students = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra
              ON s.student_id = scra.student_id 
              INNER JOIN semesters ss ON scra.semester_id = ss.semester_id
              WHERE scra.new_class_room_id = #{class_room_id} AND
              (DATE_FORMAT(ss.start_date, '%Y') = #{year} OR DATE_FORMAT(ss.end_date, '%Y') = #{year}) AND
              scra.semester_id = #{semester_id} AND s.student_id NOT IN (#{students_who_paid_ids})")

        students.each do |student|
          student_id = student.student_id
          hash[class_room_id][student_id] = {}
          student_name = student.fname.capitalize.to_s + ' ' + student.lname.capitalize.to_s
          hash[class_room_id][student_id]["name"] = student_name
          hash[class_room_id][student_id]["dob"] = student.dob
          hash[class_room_id][student_id]["email"] = student.email
          hash[class_room_id][student_id]["gender"] = student.gender
        end

        hash.delete(class_room_id) if hash[class_room_id].blank?
      end

      render :text => hash.to_json and return
    end

  end
  
end
