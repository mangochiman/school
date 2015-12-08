class ClassRoomController < ApplicationController
  def index
    @class_rooms = ClassRoom.find(:all).map(&:name)

    @totals = []
    @males = []
    @females = []

    class_rooms = ClassRoom.find(:all)
    hash = {}

    (class_rooms || []).each do |class_room|
      total_students = class_room.active_student_class_room_adjustments.count
      class_room_id = class_room.id
      hash[class_room_id] = {}
      hash[class_room_id]["total_students"] = total_students
      total_males = 0
      total_females = 0

      class_room.active_student_class_room_adjustments.each do |crs|
        next if crs.student.blank?
        if (crs.student.gender.upcase == 'MALE')
          total_males += 1
        end
        if (crs.student.gender.upcase == 'FEMALE')
          total_females += 1
        end
      end
      hash[class_room_id]["total_males"] = total_males
      hash[class_room_id]["total_females"] = total_females
    end

    @statistics = hash.sort_by{|key, value|key.to_i}

    @statistics.each do |key, value|
      @males << value["total_males"]
      @females << value["total_females"]
      @totals << value["total_students"]
    end

    
  end

  def add_class
    @class_rooms = ClassRoom.find(:all)
  end

  def edit_class
    @class_rooms = ClassRoom.all   
  end

  def edit_me
    @class_room = ClassRoom.find(params[:class_room_id])
    @class_rooms = ClassRoom.find(:all)
    if request.method == :post
      if (@class_room.update_attributes({
              :name => params[:class_name],
              :code => params[:code]
            }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :action => "edit_class" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :action => "edit_class" and return
      end
    end
    
  end
  def remove_class
    @class_rooms = ClassRoom.all
    
  end

  def delete_class_rooms
    if (params[:mode] == 'single_entry')
      class_room = ClassRoom.find(params[:class_room_id])
      class_room.delete
      render :text => "true" and return
    end

    class_room_ids = params[:class_room_ids].split(",")
    
    (class_room_ids || []).each do |class_room_id|
      class_room = ClassRoom.find(class_room_id)
      class_room.delete
    end
    
    render :text => "true" and return
  end
  
  def assign_subjects
    @class_rooms = ClassRoom.all
    
  end

  def assign_me_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = Course.all
    @my_courses = []
    (@class_room.class_room_courses || []).each do |cc|
      @my_courses << cc.course
    end
    unless (@class_room.class_room_courses.blank?)
      assigned_course_ids = @class_room.class_room_courses.collect{|c| c.course_id}
      @courses = Course.find(:all, :conditions => ["course_id NOT IN (?)", assigned_course_ids] )
    end

    if (request.method == :post)
      (params[:subjects] || []).each do |course, details|
        course_id = Course.find_by_name(course).id
        ClassRoomCourse.create({
            :class_room_id => params[:class_room_id],
            :course_id => course_id
          })
      end
      flash[:notice] = "You have successfuly assigned courses"
      redirect_to :controller => "class_room", :action => "assign_me_teachers", :class_room_id => params[:class_room_id] and return
      #redirect_to :action => "assign_me_subjects", :class_room_id => params[:class_room_id] and return
    end
    
  end
  
  def edit_subjects
    @class_rooms = ClassRoom.all
    
  end
  
  def edit_my_subjects
    @class_room = ClassRoom.find(params[:class_room_id])
    @all_courses = Course.all
    @assigned_courses = []
    
    unless (@class_room.class_room_courses.blank?)
      @assigned_courses = @class_room.class_room_courses.collect{|c| c.course}
      #@assigned_courses = Course.find(:all, :conditions => ["course_id IN (?)", assigned_course_ids] )
    end
    if (request.method == :post)
      ActiveRecord::Base.transaction do
        @class_room.class_room_courses.delete_all

        (params[:subjects] || []).each do |course, details|
          course_id = Course.find_by_name(course).id
          ClassRoomCourse.create({
              :class_room_id => params[:class_room_id],
              :course_id => course_id
            })
        end
        flash[:notice] = "You have successfuly edited courses"
        redirect_to :action => "edit_my_subjects", :class_room_id => params[:class_room_id] and return
      end
    end
    
  end
  
  def assign_teacher
    @class_rooms = ClassRoom.all
    
  end

  def assign_me_teachers
    @class_room = ClassRoom.find(params[:class_room_id])
    @teachers = Teacher.all
    
    @class_room_teachers = []
    @class_room.class_room_teachers.each do |crt|
      @class_room_teachers << crt.teacher
    end
    
    unless (@class_room.class_room_teachers.blank?)
      assigned_teacher_ids = @class_room.class_room_teachers.collect{|t| t.teacher_id}
      @teachers = Teacher.find(:all, :conditions => ["teacher_id NOT IN (?)", assigned_teacher_ids] )
    end
    
    if (request.method == :post)

      (params[:teachers] || []).each do |teacher_id, details|
        ClassRoomTeacher.create({
            :class_room_id => params[:class_room_id],
            :teacher_id => teacher_id
          })
      end
      
      flash[:notice] = "You have successfuly assigned teachers"
      redirect_to :controller => "class_room", :action => "index" and return
      #redirect_to :action => "assign_me_teachers", :class_room_id => params[:class_room_id] and return
    end
    
  end
  
  def edit_teacher
    @class_rooms = ClassRoom.all
    
  end

  def edit_my_teachers
    @class_room = ClassRoom.find(params[:class_room_id])
    @all_teachers = Teacher.all
    @assigned_teachers = []

    unless (@class_room.class_room_teachers.blank?)
      @assigned_teachers = @class_room.class_room_teachers.collect{|c| c.teacher}
      #@assigned_courses = Course.find(:all, :conditions => ["course_id IN (?)", assigned_course_ids] )
    end
    if (request.method == :post)
      ActiveRecord::Base.transaction do
        #@class_room.class_room_courses.delete_all
        assigned_teacher_ids = @assigned_teachers.map(&:teacher_id)
        already_signed_teacher_ids = []
        
        (params[:teachers] || []).each do |teacher_id, details|
          if (assigned_teacher_ids.include?(teacher_id.to_i))
            already_signed_teacher_ids << teacher_id.to_i
            next
          end
          ClassRoomTeacher.create({
              :class_room_id => params[:class_room_id],
              :teacher_id => teacher_id
            })
        end
        
        ((assigned_teacher_ids - already_signed_teacher_ids) || []).each do |teacher_id|
          class_room_teacher = @class_room.class_room_teachers.find(:last,
            :conditions => ["teacher_id =?", teacher_id])
          class_room_teacher.delete
        end
      
        flash[:notice] = "You have successfuly edited teachers"
        redirect_to :action => "edit_my_teachers", :class_room_id => params[:class_room_id] and return
      end
    end
    
  end
  
  def create_class_rooms
    class_name = params[:class_name]
    code = params[:code]
    class_name_exists = ClassRoom.find_by_name(params[:class_name])
    if (class_name_exists)
      flash[:error] = "Unable to save. Class room <b>#{params[:class_name]} already exists</b>"
      redirect_to :controller => "class_room", :action => "add_class" and return
    end
    class_room = ClassRoom.create({
        :code => code,
        :name => class_name
      })
    if (class_room)
      flash[:notice] = "You have successfully created classroom"
      redirect_to :controller => "class_room", :action => "assign_me_subjects", :class_room_id => class_room.class_room_id and return
      #redirect_to :action => "add_class" and return
    else
      flash[:error] = "Operation not successful. Check for errors and try again"
      render :action => "add_class" and return
    end
  end

  def view_classes
    @class_rooms = ClassRoom.all
    
  end
  
  def render_courses
    class_room_id = params[:class_room_id]
    class_room_courses = ClassRoom.find(class_room_id).class_room_courses
    class_name = ClassRoom.find(class_room_id).name
    course_names = {}

    (class_room_courses || []).each do |crc|
      course_names[class_name] = [] if course_names[class_name].blank?
      course_names[class_name] << crc.course.name
    end

    if class_room_courses.blank?
      course_names[class_name] = []
    end
    
    render :json => course_names.first and return
  end

  def render_students
    class_room_id = params[:class_room_id]
    class_room_students = ClassRoom.find(class_room_id).class_room_students
    class_name = ClassRoom.find(class_room_id).name
    student_data = {}
    (class_room_students || []).each do |crs|
      next if crs.student.blank?
      student_name = (crs.student.fname.to_s + ' ' + crs.student.lname.to_s)
      gender = crs.student.gender.first.capitalize.to_s
      gender = '??' if gender.blank?
      student_data[class_name] = [] if student_data[class_name].blank?
      student_data[class_name] << student_name + ' (' + gender + ')'.to_s
    end

    if (class_room_students.blank?)
      student_data[class_name] = []
    end
    
    render :json => student_data.first and return
  end

  def render_teachers
    class_room_id = params[:class_room_id]
    class_room_teachers = ClassRoom.find(class_room_id).class_room_teachers
    class_name = ClassRoom.find(class_room_id).name
    teacher_data = {}
    
    (class_room_teachers || []).each do |crt|
      teacher_name = crt.teacher.fname.to_s + ' ' + crt.teacher.lname.to_s
      gender = crt.teacher.gender.first.capitalize.to_s rescue "??"
      teacher_data[class_name] = [] if teacher_data[class_name].blank?
      teacher_data[class_name] << teacher_name + ' (' + gender + ')'.to_s
    end

    if (class_room_teachers.blank?)
      teacher_data[class_name] = []
    end
    
    render :json => teacher_data.first and return
  end

  def search_class_rooms
    class_room_name = params[:class_room_name]
    hash = {}
    class_rooms = ClassRoom.find_by_sql("SELECT * FROM class_room WHERE name LIKE '%#{class_room_name}%'")

    class_rooms.each do |class_room|
      class_room_id = class_room.class_room_id
      hash[class_room_id] = {}
      hash[class_room_id]["class_room_name"] = class_room.name.titleize
      hash[class_room_id]["code"] = class_room.code
      hash[class_room_id]["total_courses"] = class_room.class_room_courses.count
      hash[class_room_id]["total_students"] = class_room.class_room_students.count
      hash[class_room_id]["total_teachers"] = class_room.class_room_teachers.count
      hash[class_room_id]["date_created"] = class_room.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end

  def switch_class_room_menu
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def admissions_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def attendance_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def add_class_attendance
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
    
    @today = Date.today.strftime("%d/%b/%Y").upcase
    this_week_start_date = Date.today.beginning_of_week#Monday
    this_week_end_date = this_week_start_date + 4.days
    @this_week_dates = (this_week_start_date..this_week_end_date).to_a.collect{|d|d.strftime("%d/%b/%Y").upcase}
    data = []
    header = ['student_id', '#','Student Name'] + @this_week_dates
    data << header
    count = 1;
    @students.each do |student|
      student_id = student.student_id
      student_name = student.name
      student_data = [student_id, count, student_name]
      student_attendance_data = []
      @this_week_dates.each do |date|
        #pull attendance value on this date
        value = StudentAttendance.find(:last, :conditions => ["student_id =? AND
            date =?", student_id, date.to_date.to_s]).status rescue ''
        value = 'N/A' if date.to_date > Date.today
  
        student_attendance_data << value
      end
      count = count + 1
      weekly_data = (student_data + student_attendance_data)
      data << weekly_data
    end

    @data  = data.to_json
  end

  def save_attendance_data
    attendance_data = params[:attendance_data]
    header = attendance_data["0"]
    # Remove these fields from the header "student_id", "#", "Student Name"
    #We want dates only
    #["student_id", "#", "Student Name", "07/DEC/2015", "08/DEC/2015", "09/DEC/2015", "10/DEC/2015", "11/DEC/2015"]
    weekly_dates = []
    3.upto(header.length - 1) do |i|
      weekly_dates << header[i]
    end

    attendance_data.delete("0") #Remove the first row with "0" as its key
    attendance_data.each do |key, values|
      student_id = values[0]
      student_data = []
      #"1"=>["1", "1", "Joseph Banda", "Present", "Sick", "N/A", "N/A", "N/A"]
      3.upto(values.length - 1) do |i|
        student_data << values[i]
      end

      student_data.each_with_index do |value, index|
        date_of_attendance = weekly_dates[index]
        attendance_value = value
        next if date_of_attendance.to_date > Date.today #Ignore the future dates
        student_attendance = StudentAttendance.find(:last, :conditions => ["student_id =? AND
            date =?", student_id, date_of_attendance.to_date.to_s])
        student_attendance = StudentAttendance.new if student_attendance.blank?
        student_attendance.student_id = student_id
        student_attendance.date = date_of_attendance.to_date
        student_attendance.status = attendance_value
        student_attendance.save
      end
    end

    render :text => true and return
  end
  
  def behavior_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def add_class_punishments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def create_student_punishment
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @student_punishments = @student.student_punishments.collect{|sp|sp.punishment}
  end

  def new_punishment
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @teachers = Teacher.all
    @punishment_types = PunishmentType.all

    if request.method == :post
      punishment_type_id = params[:punishment_type_id]
      teacher_id = params[:teacher_id]
      start_date = params[:start_date]
      end_date = params[:end_date]
      punishment_details = params[:punishment_details]

      punishment =  Punishment.create({
          :teacher_id => teacher_id,
          :punishment_type_id => punishment_type_id,
          :start_date => start_date,
          :end_date => end_date,
          :details => punishment_details,
        })

      StudentPunishment.create({
          :student_id => params[:student_id],
          :punishment_id => punishment.punishment_id,
          :completed => 0
        })

      redirect_to("/class_room/create_student_punishment?class_room_id=#{params[:class_room_id]}&student_id=#{params[:student_id]}") and return
    end

  end

  def edit_punishment
    @class_room = ClassRoom.find(params[:class_room_id])
    @punishment = Punishment.find(params[:punishment_id])
    @student = Student.find(params[:student_id])
    @teachers = Teacher.all
    @punishment_types = PunishmentType.all
  end

  def update_punishment
    @punishment = Punishment.find(params[:punishment_id])
    if (request.method == :post)
      punishment_type_id = params[:punishment_type_id]
      teacher_id = params[:teacher_id]
      start_date = params[:start_date]
      end_date = params[:end_date]
      punishment_details = params[:punishment_details]

      if (@punishment.update_attributes({
              :teacher_id => teacher_id,
              :punishment_type_id => punishment_type_id,
              :start_date => start_date,
              :end_date => end_date,
              :details => punishment_details,
            }))
        flash[:notice] = "Operation successful"
        redirect_to("/class_room/create_student_punishment?class_room_id=#{params[:class_room_id]}&student_id=#{params[:student_id]}") and return
      else
        flash[:error] = "Unable to save. Check for errors and try again"
        redirect_to("/class_room/edit_punishment?class_room_id=#{params[:class_room_id]}&punishment_id=#{params[:punishment_id]}&student_id=#{params[:student_id]}") and return
      end
    end
  end

  def view_class_punishments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def view_student_punishments
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @student_punishments = @student.student_punishments.collect{|sp|sp.punishment}
  end
  
  def void_class_punishments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def void_student_punishments
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @student_punishments = @student.student_punishments.collect{|sp|sp.punishment}
    @punishment_types = PunishmentType.all
  end

  def sort_punishments
    sort_key = params["sort_key"]
    field = sort_key.split(' ')[0]
    asc_or_desc = sort_key.split(' ')[1]
  
    punishments = Punishment.find_by_sql("SELECT p.* FROM punishment p INNER JOIN student_punishment sp
        ON p.punishment_id = sp.punishment_id AND sp.student_id = #{params[:student_id]}
        ORDER BY p.#{field} #{asc_or_desc}")

    punishment_data = []
    punishments.each do |punishment|
      punishment_type = punishment.punishment_type.name
      punishment_details = punishment.details
      teacher = punishment.teacher.name
      start_date = punishment.start_date.to_date.strftime("%d-%b-%Y")
      end_date = punishment.end_date.to_date.strftime("%d-%b-%Y")
      punishment_data << [punishment_type, punishment_details, teacher, start_date, end_date]
    end

    render :json => punishment_data and return
  end

  def examinations_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def add_examination
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
    
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}

    @examinations = Examination.find(:all)
  end

  def create_exam_assignment
    class_room_id = params[:class_room_id] #Add semester field in an exam table
    exam_type = params[:exam_type]
    course_id = params[:course]
    exam_date = params[:exam_date]

    ActiveRecord::Base.transaction do
      exam = Examination.new
      exam.class_room_id = class_room_id
      exam.exam_type_id = exam_type
      exam.course_id = course_id
      exam.start_date = exam_date.to_date
      exam.save!

      (params[:students] || []).each do |student_id, details|
        exam_attendee = ExamAttendee.new
        exam_attendee.exam_id = exam.id
        exam_attendee.student_id = student_id
        exam_attendee.save!
      end

    end
    
    flash[:notice] = "Operation successful"
    redirect_to("/class_room/add_examination?class_room_id=#{params[:class_room_id]}") and return

  end

  def edit_examination
    @class_room = ClassRoom.find(params[:class_room_id])
    @exams = @class_room.examinations
    
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
  end

  def exam_record_edit
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
    
    exam = Examination.find(params[:exam_id])
    @exam_date = exam.start_date.to_date.strftime("%Y-%m-%d")

    @exam_attendees = exam.students.map(&:id)
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}
    @selected_exam_type = [exam.examination_type.name, exam.examination_type.id]

    @courses = [["---Select Course---", ""]]
    @selected_course = [(exam.course.name rescue nil), (exam.course.id rescue nil)]
    courses = exam.class_room.class_room_courses.collect{|crc|crc.course}
    @courses += courses.collect{|c|[c.name, c.id]}

  end

  def update_exam_assignment
    exam_id = params[:exam_id]
    exam_type = params[:exam_type]
    course_id = params[:course]
    exam_date = params[:exam_date]
    exam = Examination.find(exam_id)

    ActiveRecord::Base.transaction do
      exam.update_attributes({
          :exam_type_id => exam_type,
          :course_id => course_id,
          :start_date => exam_date
        })


      exam.exam_attendees.each do |exam_attend|
        exam_attend.delete
      end

      (params[:students] || []).each do |student_id, details|
        exam_attendee = ExamAttendee.new
        exam_attendee.exam_id = exam_id
        exam_attendee.student_id = student_id
        exam_attendee.save!
      end

    end

    flash[:notice] = "Operation successful"
    redirect_to("/class_room/edit_examination?class_room_id=#{params[:class_room_id]}") and return
  end
  
  def view_examination
    @class_room = ClassRoom.find(params[:class_room_id])
    @exams = @class_room.examinations

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
  end

  def void_examination
    @class_room = ClassRoom.find(params[:class_room_id])
    @exams = @class_room.examinations

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
  end

  def add_examination_results
    @class_room = ClassRoom.find(params[:class_room_id])
    @exams = Examination.find_by_sql("SELECT e.* FROM exam e LEFT JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]}
     WHERE er.exam_id IS NULL") #Exams without results

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
    
  end

  def add_exam_result
    @class_room = ClassRoom.find(params[:class_room_id])

    @exam = Examination.find(params[:exam_id])
    @students = @exam.students

    @exams_without_results = Examination.find_by_sql("SELECT e.* FROM exam e LEFT JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]} WHERE er.exam_id IS NULL")
  end

  def create_exam_result
    ActiveRecord::Base.transaction do
      (params[:students] || []).each do |student_id, result|
        next if result.blank?
        ExaminationResult.create({
            :exam_id => params[:exam_id],
            :student_id => student_id,
            :marks => result.to_i
          })
      end
    end

    flash[:notice] = "Operation successful"
    redirect_to("/class_room/add_examination_results?class_room_id=#{params[:class_room_id]}") and return
  end
  
  def edit_examination_results
    @class_room = ClassRoom.find(params[:class_room_id])
    
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}

    @exams = Examination.find_by_sql("SELECT e.* FROM exam e INNER JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]} GROUP BY e.exam_id")
  end

  def edit_exam_result_record
    @class_room = ClassRoom.find(params[:class_room_id])

    @exam = Examination.find(params[:exam_id])
    @students = @exam.students
    @exams_with_results = Examination.find_by_sql("SELECT e.* FROM exam e INNER JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]}")
  end

  def update_exam_result_record
    @exam = Examination.find(params[:exam_id])
    ActiveRecord::Base.transaction do

      @exam.examination_results.each do |result|
        result.delete
      end

      (params[:students] || []).each do |student_id, result|
        next if result.blank?
        ExaminationResult.create({
            :exam_id => params[:exam_id],
            :student_id => student_id,
            :marks => result.to_i
          })
      end
      flash[:notice] = "Operation successful"
    end

    redirect_to("/class_room/edit_examination_results?class_room_id=#{params[:class_room_id]}") and return
  end

  def view_examination_results
    @class_room = ClassRoom.find(params[:class_room_id])
    
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
    @exams = Examination.find_by_sql("SELECT e.* FROM exam e INNER JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]} GROUP BY e.exam_id")
  end

  def void_examination_results
    @class_room = ClassRoom.find(params[:class_room_id])

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += @class_room.class_room_courses.collect{|crc|[crc.course.name, crc.course.course_id]}
    @exams = Examination.find_by_sql("SELECT e.* FROM exam e INNER JOIN exam_result er
      ON e.exam_id = er.exam_id AND e.class_room_id = #{params[:class_room_id]} GROUP BY e.exam_id")
  end

  def payments_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def add_student_payment
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def create_student_payment
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])

    @payment_types = [["[Payment Type]", ""]]
    @payment_types += PaymentType.all.collect{|c|[c.name, c.id]}

    @current_student_payments = Payment.find(:all, :conditions => ["student_id =?",
        params[:student_id]])
    @current_semester_audit_id = Semester.current_active_semester_audit.semester_audit_id rescue ''
    #@current_semester_id = Semester.current_active_semester_audit.semester_id rescue ''

    @payment_types_hash = {}
    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    previous_payments = @student.payments

    @payments_hash = {}

    previous_payments.each do |payment|
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      latest_payment = @student.payments.find(:first, :order => "DATE(date) DESC",
        :conditions => ["payment_type_id =?", payment_type_id]) if @payments_hash[payment_type_id].blank?

      @payments_hash[payment_type_id]["amount_required"] = payment.payment_type.amount_required.to_i
      @payments_hash[payment_type_id]["amount_paid"] = 0 if @payments_hash[payment_type_id]["amount_paid"].blank?
      @payments_hash[payment_type_id]["amount_paid"] += payment.amount_paid.to_i
      @payments_hash[payment_type_id]["balance"] = payment.payment_type.amount_required.to_i if @payments_hash[payment_type_id]["balance"].blank?
      @payments_hash[payment_type_id]["balance"] -= payment.amount_paid.to_i
      @payments_hash[payment_type_id]["latest_date_paid"] = latest_payment.date.to_date.strftime("%d-%b-%Y") if latest_payment
    end

    if (request.method == :post)
      student_id = params[:student_id]
      payment_type = params[:payment_type]
      semester_audit_id = params[:semester]
      amount_paid = params[:amount]
      date_paid = params[:payment_date]

      if (Payment.new_payment(student_id, payment_type, amount_paid, date_paid, semester_audit_id))
        flash[:notice] = "Operation successful"
        redirect_to("/class_room/add_student_payment?class_room_id=#{params[:class_room_id]}") and return
      else
        flash[:error] = "Unable to save the details. Check for the errors and try again"
        redirect_to("/class_room/create_student_payment?class_room_id=#{params[:class_room_id]}&student_id=#{student_id}") and return
      end
    end
    
  end

  def edit_student_payments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def edit_selected_student_payment
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @payments_hash = {}
    @payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
    end
  end

  def edit_particular_payment
    @class_room = ClassRoom.find(params[:class_room_id])
    
    payment_id = params[:payment_id]
    @payment = Payment.find(payment_id)
    @student = Student.find(@payment.student_id)
    previous_payments = @student.payments
    @payments_hash = {}
    @payment_types_hash = {}
    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    previous_payments.each do |payment|
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      latest_payment = @student.payments.find(:first, :order => "DATE(date) DESC",
        :conditions => ["payment_type_id =?", payment_type_id]) if @payments_hash[payment_type_id].blank?

      @payments_hash[payment_type_id]["amount_required"] = payment.payment_type.amount_required.to_i
      @payments_hash[payment_type_id]["amount_paid"] = 0 if @payments_hash[payment_type_id]["amount_paid"].blank?
      @payments_hash[payment_type_id]["amount_paid"] += payment.amount_paid.to_i
      @payments_hash[payment_type_id]["balance"] = payment.payment_type.amount_required.to_i if @payments_hash[payment_type_id]["balance"].blank?
      @payments_hash[payment_type_id]["balance"] -= payment.amount_paid.to_i
      @payments_hash[payment_type_id]["latest_date_paid"] = latest_payment.date.to_date.strftime("%d-%b-%Y") if latest_payment
    end

    if request.method == :post
      amount_paid = params[:amount]
      date_paid = params[:payment_date]
      if (@payment.update_attributes({:amount_paid => amount_paid, :date => date_paid}))
        flash[:notice] = "Operation successful"
        redirect_to("/class_room/edit_selected_student_payment?class_room_id=#{params[:class_room_id]}&student_id=#{@student.student_id}")
      else
        flash[:error] = "Unable to save the details. Check for the errors and try again"
        render :controller => "payments", :action => "edit_my_payments_menu", :student_id => @student.student_id and return
      end
    end
    
  end
  
  def view_student_payments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def view_my_payments
    @class_room = ClassRoom.find(params[:class_room_id])
    student_id = params[:student_id]
    @student = Student.find(student_id)
    @payments_hash = {}
    @payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
      @payments_hash[payment_type_id][payment_id]["date_created"] = payment.created_at.to_date.strftime("%d-%b-%Y")
    end
    
  end

  def student_class_room_payments_search
    student_id = params[:student_id]
    student = Student.find(student_id)
    payments_hash = {}
    payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      payment_types_hash[payment_type.id] = payment_type.name
    end

    student_payments = student.payments.find(:all, :conditions => ["semester_audit_id =?", params[:semester_audit_id]])
    student_payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      payments_hash[payment_type_id] = {} if payments_hash[payment_type_id].blank?
      payments_hash[payment_type_id][payment_id] = {}
      payments_hash[payment_type_id][payment_id]["amount_paid"] = ActionController::Base.helpers.number_to_currency(payment.amount_paid.to_i, :unit => 'MK')
      payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
      payments_hash[payment_type_id][payment_id]["date_created"] = payment.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => [payments_hash, payment_types_hash] and return
  end
  
  def view_class_payments
    @class_room = ClassRoom.find(params[:class_room_id])
    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")

    @payments_hash = {}
    @payment_types_hash = {}

    current_semester_audit_id = Semester.current_active_semester_audit.semester_audit_id rescue ''
    active_semester_audit = Semester.current_active_semester_audit
    start_date = Semester.current_semester_start_date.to_date.strftime("%d-%b-%Y") rescue '??/??/????'
    end_date = Semester.current_semester_end_date.to_date.strftime("%d-%b-%Y") rescue '??/??/????'
    @semester_details = active_semester_audit.semester_id.to_s + ' (' +  start_date + ' to ' + end_date + ')'

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    students.each do |student|
      student_id = student.student_id
      student_payments = student.payments.find(:all,
        :conditions => ["semester_audit_id =?", current_semester_audit_id])
      
      student_payments.each do |payment|
        payment_type_id = payment.payment_type_id
        @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
        @payments_hash[payment_type_id][student_id] = {} if @payments_hash[payment_type_id][student_id].blank?
        @payments_hash[payment_type_id][student_id][payment_type_id] = {} if @payments_hash[payment_type_id][student_id][payment_type_id].blank?
        @payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"] = 0 if @payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"].blank?
        @payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"] += payment.amount_paid.to_i
        @payments_hash[payment_type_id][student_id][payment_type_id]["semester_audit_id"] = current_semester_audit_id
      end

    end
    
  end

  def class_room_payments_search
    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")

    payments_hash = {}
    payment_types_hash = {}

    semester_audit_id = params[:semester_audit_id]
    selected_semester_audit = SemesterAudit.find(semester_audit_id)
    start_date = selected_semester_audit.start_date.to_date.strftime("%d-%b-%Y") rescue '??/??/????'
    end_date = selected_semester_audit.end_date.to_date.strftime("%d-%b-%Y") rescue '??/??/????'
    semester_details = selected_semester_audit.semester_id.to_s + ' (' +  start_date + ' to ' + end_date + ')'

    (PaymentType.all || []).each do |payment_type|
      payment_types_hash[payment_type.id] = payment_type.name
    end

    students.each do |student|
      student_id = student.student_id
      student_name = student.name
      student_payments = student.payments.find(:all,
        :conditions => ["semester_audit_id =?", params[:semester_audit_id]])

      student_payments.each do |payment|
        payment_type_id = payment.payment_type_id
        payments_hash[payment_type_id] = {} if payments_hash[payment_type_id].blank?
        payments_hash[payment_type_id][student_id] = {} if payments_hash[payment_type_id][student_id].blank?
        payments_hash[payment_type_id][student_id][payment_type_id] = {} if payments_hash[payment_type_id][student_id][payment_type_id].blank?
        payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"] = 0 if payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"].blank?
        payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"] += payment.amount_paid.to_i
        total_amount_paid = payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid"]
        payments_hash[payment_type_id][student_id][payment_type_id]["total_amount_paid_formatted"] = ActionController::Base.helpers.number_to_currency(total_amount_paid, :unit => 'MK')
        payments_hash[payment_type_id][student_id][payment_type_id]["semester_audit_id"] = semester_audit_id
        payments_hash[payment_type_id][student_id][payment_type_id]["student_name"] = student_name
      end

    end

    render :json => [semester_details, payments_hash, payment_types_hash] and return
  end
  
  def student_payment_details
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @payment_type = PaymentType.find(params[:payment_type_id])
    @student_payments = Payment.find(:all, :conditions => ["student_id =? AND payment_type_id =?
      AND semester_audit_id =?", params[:student_id], params[:payment_type_id], params[:semester_audit_id]])
  end
  
  def void_student_payments
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def void_my_payments_menu
    @class_room = ClassRoom.find(params[:class_room_id])

    student_id = params[:student_id]
    @student = Student.find(student_id)
    @payments_hash = {}
    @payment_types_hash = {}

    (PaymentType.all || []).each do |payment_type|
      @payment_types_hash[payment_type.id] = payment_type.name
    end

    @student.payments.each do |payment|
      payment_id = payment.id
      payment_type_id = payment.payment_type_id
      @payments_hash[payment_type_id] = {} if @payments_hash[payment_type_id].blank?
      @payments_hash[payment_type_id][payment_id] = {}
      @payments_hash[payment_type_id][payment_id]["amount_paid"] = payment.amount_paid.to_i
      @payments_hash[payment_type_id][payment_id]["date_paid"] = payment.date.to_date.strftime("%d-%b-%Y")
    end
  end
  
  def courses_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def add_class_course
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = @class_room.class_room_courses.collect{|crc|crc.course rescue ''}.compact
  end

  def add_new_class_course
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def create_new_class_course
    course_exists = Course.find_by_name(params[:course_name])

    if course_exists
      flash[:error] = "Unable to save. Course name already exists"
      redirect_to("/class_room/add_new_class_course?class_room_id=#{params[:class_room_id]}")and return
    end

    optional = false
    optional = true if params[:optional]

    ActiveRecord::Base.transaction do
      course = Course.create({
          :name => params[:course_name],
          :optional => optional
        })

      ClassRoomCourse.create({
          :class_room_id => params[:class_room_id],
          :course_id => course.course_id
        })
    end

    flash[:notice] = "Operation successful"
    redirect_to("/class_room/add_class_course?class_room_id=#{params[:class_room_id]}")and return

  end

  def edit_me_class_course
    @class_room = ClassRoom.find(params[:class_room_id])
    class_room_course = ClassRoomCourse.find(:last, :conditions => ["class_room_id =? AND course_id =?",
        params[:class_room_id], params[:course_id]])
    @course = class_room_course.course
    
    if request.method ==:post
      optional = false
      optional = true if params[:optional]
      if (@course.update_attributes({
              :name => params[:course_name],
              :optional => optional
            }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to "/class_room/edit_class_courses?class_room_id=#{params[:class_room_id]}" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to "/class_room/edit_me_class_course?class_room_id=#{params[:class_room_id]}&course_id=#{params[:course_id]}" and return
      end
    end

  end

  def search_class_room_courses
    courses = Course.find_by_sql("SELECT c.* FROM course c INNER JOIN class_room_course crc 
      ON c.course_id = crc.course_id WHERE crc.class_room_id = '#{params[:class_room_id]}'
      AND c.name LIKE '%#{params[:course_name]}%'")

    hash = {}
    courses.each do |course|
      course_id = course.course_id
      hash[course_id] = {}
      hash[course_id]["course_name"] = course.name
    end
    
    render :json => hash and return
  end

  def edit_class_courses
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = @class_room.class_room_courses.collect{|crc|crc.course rescue ''}.compact
  end

  def view_class_courses
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = @class_room.class_room_courses.collect{|crc|crc.course rescue ''}.compact
  end

  def void_class_courses
    @class_room = ClassRoom.find(params[:class_room_id])
    @courses = @class_room.class_room_courses.collect{|crc|crc.course rescue ''}.compact
  end
  
  def teachers_tab
    @class_room = ClassRoom.find(params[:class_room_id])
  end

  def student_admissions
    @class_room = ClassRoom.find(params[:class_room_id])
    if (request.method == :post)
      first_name = params[:firstname]
      last_name = params[:lastname]
      gender = params[:gender]
      email = params[:email]
      phone = params[:phone]
      date_of_birth = params[:dob].to_date

      ActiveRecord::Base.transaction do
        student = Student.create({
            :fname => first_name,
            :lname => last_name,
            :gender => gender,
            :email => email,
            :phone => phone,
            :dob => date_of_birth
          })
        
        student.student_class_room_adjustments.create({
            :old_class_room_id => 0,
            :new_class_room_id => params[:class_room_id],
            :status => 'active'
          })

        class_room_courses = ClassRoom.find(params[:class_room_id]).class_room_courses
        (class_room_courses || []).each do |course|
          StudentClassRoomCourse.create({
              :student_id => student.student_id,
              :class_room_id => params[:class_room_id],
              :course_id => course.course_id
            })
        end
        
      end

    end
    
  end

  def student_courses
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def student_class_room_courses
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @student_courses = @student.student_class_room_courses.find(:all,
      :conditions => ["class_room_id =?",  params[:class_room_id]]).collect{|scrc|scrc.course}
    @un_assigned_courses = ClassRoomCourse.find_by_sql("SELECT crc.* FROM class_room_course crc 
        LEFT JOIN student_class_room_course scrc ON scrc.course_id = crc.course_id
        AND scrc.student_id = #{params[:student_id]} WHERE crc.class_room_id=#{params[:class_room_id]}
        AND scrc.course_id IS NULL;
      ").collect{|scrc|scrc.course}.compact
  end
  
  def student_guardians
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def student_class_room_guardians
    @class_room = ClassRoom.find(params[:class_room_id])
    @student = Student.find(params[:student_id])
    @guardians = @student.student_parents.collect{|sp|sp.parent}
    @un_assigned_guardians = Parent.find_by_sql("SELECT p.* FROM parent p
        LEFT JOIN student_parent sp ON p.parent_id = sp.parent_id
        AND sp.student_id = #{params[:student_id]} WHERE sp.parent_id IS NULL
      ")
  end

  def delete_student_guardian
    if (params[:mode] == 'single_entry')
      student_parent = StudentParent.find(:last, :conditions => ["student_id =? AND
         parent_id =?", params[:student_id], params[:guardian_id]])
      student_parent.delete
      render :text => "true" and return
    end

    parent_ids = params[:guardian_ids].split(",")

    (parent_ids || []).each do |parent_id|
      student_parent = StudentParent.find(:last, :conditions => ["student_id =? AND
         parent_id =?", params[:student_id], parent_id])
      student_parent.delete
    end

    render :text => "true" and return
  end
  
  def create_student_parent
    first_name = params[:firstname]
    last_name = params[:lastname]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    date_of_birth = params[:dob].to_date

    password = params[:password]
    password_confirm = params[:password_confirm]
    errors = ""
    user_exists = Parent.find_by_username(params[:username])
    errors += 'Username already exists.' if user_exists
    errors += ' Password mismatch.' if (password != password_confirm)

    unless (errors.blank?)
      flash[:error] = "#{errors}"
      redirect_to("/class_room/student_class_room_guardians?class_room_id=#{params[:class_room_id]}&student_id=#{params[:student_id]}") and return
    end

    ActiveRecord::Base.transaction do
      parent = Parent.create({
          :fname => first_name,
          :lname => last_name,
          :password => password,
          :username => params[:username],
          :gender => gender,
          :email => email,
          :phone => phone,
          :dob => date_of_birth
        })

      StudentParent.create({
          :student_id => params[:student_id],
          :parent_id => parent.parent_id
        })

    end

    redirect_to("/class_room/student_class_room_guardians?class_room_id=#{params[:class_room_id]}&student_id=#{params[:student_id]}") and return
  end

  def create_student_select_guardian
    url =  request.referrer
    StudentParent.create({
        :student_id => params[:student_id],
        :parent_id => params[:parent_id]
      })
    
    redirect_to(url) and return
  end
  
  def student_archieve
    @class_room = ClassRoom.find(params[:class_room_id])
    @students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")
  end

  def view_class_archived_students
    @class_room = ClassRoom.find(params[:class_room_id])
    @archived_students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NOT NULL")
  end

  def search_class_archived_students
    first_name = params[:first_name]
    last_name = params[:last_name]
    class_room_id = params[:class_room_id]

    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{class_room_id}
          AND scra.status = 'active' AND sa.student_id IS NOT NULL
          AND s.fname LIKE '%#{first_name}%' AND s.lname LIKE '%#{last_name}%'")

    hash = {}
    students.each do |student|
      student_id = student.id.to_s
      hash[student_id] = {}
      hash[student_id]["fname"] = student.fname.to_s
      hash[student_id]["lname"] = student.lname.to_s
      hash[student_id]["phone"] = student.phone
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["dob"] = student.dob.to_date.strftime("%d-%b-%Y")
      hash[student_id]["join_date"] = student.created_at.to_date.strftime("%d-%b-%Y") rescue ''
      hash[student_id]["current_class"] = student.current_class
      hash[student_id]["current_active_class"] = student.current_active_class
      hash[student_id]["total_photos"] = student.student_photos.count
      hash[student_id]["guardian_details"] = student.guardian_details
      hash[student_id]["date_archived"] = student.student_archive.date_archived.to_date.strftime("%d-%b-%Y") rescue ''
      hash[student_id]["archive_reason"] = student.student_archive.reason
    end

    render :json => hash
  end
  
  def student_view
    @class_room = ClassRoom.find(params[:class_room_id])

    @active_students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NULL")

    @archived_students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{params[:class_room_id]}
          AND scra.status = 'active' AND sa.student_id IS NOT NULL")

  end

  def class_room_students_search
    first_name = params[:first_name]
    last_name = params[:last_name]
    class_room_id = params[:class_room_id]
    
    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.new_class_room_id = #{class_room_id}
          AND scra.status = 'active' AND sa.student_id IS NULL
          AND s.fname LIKE '%#{first_name}%' AND s.lname LIKE '%#{last_name}%'")
    
    hash = {}
    students.each do |student|
      student_id = student.id.to_s
      hash[student_id] = {}
      hash[student_id]["fname"] = student.fname.to_s
      hash[student_id]["lname"] = student.lname.to_s
      hash[student_id]["phone"] = student.phone
      hash[student_id]["email"] = student.email
      hash[student_id]["gender"] = student.gender
      hash[student_id]["dob"] = student.dob.to_date.strftime("%d-%b-%Y")
      hash[student_id]["join_date"] = student.created_at.to_date.strftime("%d-%b-%Y")
      hash[student_id]["guardian_details"] = student.guardian_details
    end

    render :json => hash
  end

  def delete_student_class_room_courses
    if (params[:mode] == 'single_entry')
      student_class_room_course = StudentClassRoomCourse.find(:last,
        :conditions => ["student_id =? AND class_room_id =? AND course_id =?",
          params[:student_id], params[:class_room_id], params[:course_id]])
      student_class_room_course.delete
      render :text => "true" and return
    end

    course_ids = params[:course_ids].split(",")

    (course_ids || []).each do |course_id|
      student_class_room_course = StudentClassRoomCourse.find(:last,
        :conditions => ["student_id =? AND class_room_id =?  AND course_id =?",
          params[:student_id], params[:class_room_id], course_id])
      student_class_room_course.delete
    end

    render :text => "true" and return
  end

  def add_student_class_room_courses
    if (params[:mode] == 'single_entry')
      StudentClassRoomCourse.create({
          :student_id => params[:student_id],
          :class_room_id => params[:class_room_id],
          :course_id => params[:course_id]
        })
      render :text => "true" and return
    end

    course_ids = params[:course_ids].split(",")
    (course_ids || []).each do |course_id|
      StudentClassRoomCourse.create({
          :student_id => params[:student_id],
          :class_room_id => params[:class_room_id],
          :course_id => course_id
        })
    end

    render :text => "true" and return
  end

end
