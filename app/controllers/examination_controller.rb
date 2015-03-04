class ExaminationController < ApplicationController
  def index
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}
    
    @exam_types = [["All", "All"]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}

    @courses = [["---Select Course---", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}

    first_exam = Examination.first
    @first_exam_class_room = first_exam.class_room_id rescue nil
    @first_exam_type = first_exam.exam_type_id rescue nil
    @first_exam_year = first_exam.start_date.to_date.year rescue nil
    @first_exam_course = first_exam.course_id rescue nil

    @exams_per_month = []
    @exam_without_results = []
    @exam_with_results = []

    (1..12).to_a.each do |month_number|
      course_exams = Examination.find(:all, :conditions => ["class_room_id =? AND exam_type_id =?
          AND course_id =? AND DATE_FORMAT(start_date, '%m') =? AND DATE_FORMAT(start_date, '%Y') =?",
          (first_exam.class_room_id rescue nil), (first_exam.exam_type_id rescue nil),
          (first_exam.course_id rescue nil),
          (month_number rescue nil), (first_exam.start_date.to_date.year rescue nil)])
      without_results = 0
      with_results = 0
      (course_exams || []).each do |course_exam|
        if (course_exam.examination_results.blank?)
          without_results += 1
        end

        unless (course_exam.examination_results.blank?)
          with_results += 1
        end
      end

      total_exams_per_month = course_exams.count
      @exams_per_month << total_exams_per_month
      @exam_without_results << without_results
      @exam_with_results << with_results
    end
    
    start_year = (Date.today.year - 5)
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    class_rooms = ClassRoom.all
    hash = {}
    class_rooms.each do |class_room|
      class_room_id = class_room.id
      hash[class_room_id] = {}
      class_room.class_room_courses.each do |crc|
        course_id = crc.course_id
        course_name = crc.course.name
        hash[class_room_id][course_id] = course_name
      end
    end
    
    @class_courses = hash.to_json
    
  end

  def plot_graph
    class_room_id = params[:class_room_id]
    exam_type_ids = params[:exam_type_id]
    if (params[:exam_type_id].upcase == 'ALL')
      exam_type_ids = ExaminationType.all.map(&:id).join(', ')
    end
    year = params[:year]
    course_id = params[:course_id]

    @exams_per_month = []
    @exams_without_results = []
    @exams_with_results = []
    
    (1..12).to_a.each do |month_number|
      course_exams = Examination.find(:all, :conditions => ["class_room_id =? AND exam_type_id IN (#{exam_type_ids})
          AND course_id =? AND DATE_FORMAT(start_date, '%m') =? AND DATE_FORMAT(start_date, '%Y') =?",
          class_room_id, course_id,
          month_number, year])
      
      without_results = 0
      with_results = 0
      (course_exams || []).each do |course_exam|
        if (course_exam.examination_results.blank?)
          without_results += 1
        end

        unless (course_exam.examination_results.blank?)
          with_results += 1
        end
      end

      total_exams_per_month = course_exams.count
      @exams_per_month << total_exams_per_month
      @exams_without_results << without_results
      @exams_with_results << with_results
    end
    hash = {}
    hash["exams_per_month"] = @exams_per_month
    hash["exams_without_results"] = @exams_without_results
    hash["exams_with_results"] = @exams_with_results
    render :text => hash.to_json and return
  end
  
  def new_exam_type
    if (request.method == :post)
      if (ExaminationType.create({
              :name => params[:exam_type]
            }))
        flash[:notice] = "You have successfully added exam type"
        redirect_to :action => "new_exam_type" and return
      end
    end

    
  end

  def edit_exam_type
    @exam_types = ExaminationType.all
    
  end

  def edit_me
    @exam_type = ExaminationType.find(params[:exam_type_id])
    
    if (request.method == :post)
      if (@exam_type.update_attributes({
              :name => params[:exam_type]
            }))

        flash[:notice] = "You have successfully edited exam type"
        redirect_to :action => "edit_exam_type" and return
      else
        flash[:error] = "Operation aborted"
        redirect_to :action => "edit_me", :exam_type_id => params[:exam_type_id]
      end
    end

    
  end

  def exam_edit
    exam = Examination.find(params[:exam_id])
    @exam_date = exam.start_date.to_date.strftime("%Y-%m-%d")
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}
    @selected_class_room = [exam.class_room.name, exam.class_room.id]
    @class_room_id = exam.class_room.id
    @exam_attendees = exam.students.map(&:id)
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}
    @selected_exam_type = [exam.examination_type.name, exam.examination_type.id]

    @courses = [["---Select Course---", ""]]
    @selected_course = [(exam.course.name rescue nil), (exam.course.id rescue nil)]
    courses = exam.class_room.class_room_courses.collect{|crc|crc.course}
    @courses += courses.collect{|c|[c.name, c.id]}

    @examinations = Examination.find(:all)
    
  end

  def update_exams
    exam_id = params[:exam_id]
    class_room_id = params[:class_room]
    exam_type = params[:exam_type]
    course_id = params[:course]
    exam_date = params[:exam_date]
    exam = Examination.find(exam_id)

    ActiveRecord::Base.transaction do
      exam.update_attributes({
          :class_room_id => class_room_id,
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
    redirect_to :controller => "examination", :action => "edit_exam_assignment" and return
  end
  
  def void_exam_type
    @exam_types = ExaminationType.all
    
  end
  
  def assign_exam
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|c|[c.name, c.id]}

    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|e|[e.name, e.id]}
    
    @courses = [["---Select Course---", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}

    @examinations = Examination.find(:all)
  end

  def create_exam_assignment
    class_room_id = params[:class_room] #Add class_room_id field in an exam table
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
    redirect_to :controller => "examination", :action => "assign_exam"
  end
  
  def edit_exam_assignment
    @exams = Examination.all
    
  end

  def void_exam
    @exams = Examination.all
    
  end

  def delete_exams
    if (params[:mode] == 'single_entry')
      exam = Examination.find(params[:exam_id])
      exam.delete
      render :text => "true" and return
    end

    exam_ids = params[:exam_ids].split(",")
    (exam_ids || []).each do |exam_id|
      exam_id = Examination.find(exam_id)
      exam_id.delete
    end

    render :text => "true" and return
  end
  
  def delete_exam_types
    if (params[:mode] == 'single_entry')
      exam_type = ExaminationType.find(params[:exam_type_id])
      exam_type.delete
      render :text => "true" and return
    end

    exam_type_ids = params[:exam_type_ids].split(",")
    (exam_type_ids || []).each do |exam_type_id|
      exam_type = ExaminationType.find(exam_type_id)
      exam_type.delete
    end
    
    render :text => "true" and return
  end

  def class_room_students
    students = []
    class_room_adjustments = StudentClassRoomAdjustment.find(:all,
      :conditions => ["status =? AND new_class_room_id =?", 'active', params[:class_room_id]])
    
    class_room_adjustments.each do |adjustment|
      next if adjustment.student.blank?
      students << adjustment.student
    end
    
    students = (students || []).collect{|s|[s.id, s.fname + ' ' + s.lname]}.in_groups_of(3)
    render :json => students and return
  end

  def class_room_courses
    unless params[:class_room_id].blank?
      class_room = ClassRoom.find(params[:class_room_id])
      options = [["", "---Select Course---"]]
      courses = class_room.class_room_courses.collect{|crc| crc.course}.compact
      options += (courses || []).collect{|c|[c.id, c.name]}
    else
      options = []
    end
    render :json => options and return
  end

  def render_students
    exam_id = params[:exam_id]
    exam_attendees = Examination.find(exam_id).students
    class_name = Examination.find(exam_id).class_room.name
    student_data = {}
    
    (exam_attendees || []).each do |et|
      student_name = (et.fname.to_s + ' ' + et.lname.to_s)
      gender = et.gender.first.capitalize.to_s
      gender = '??' if gender.blank?
      student_data[class_name] = [] if student_data[class_name].blank?
      student_data[class_name] << student_name + ' (' + gender + ')'.to_s
    end

    render :json => student_data.first and return
  end

  def render_exam_results
    exam_id = params[:exam_id]
    exam_results = Examination.find(exam_id).examination_results
    class_name = Examination.find(exam_id).class_room.name
    student_data = {}
    student_data[class_name] = []

    (exam_results || []).each do |er|
      student_name = (er.student.fname.to_s + ' ' + er.student.lname.to_s)
      gender = er.student.gender.first.capitalize.to_s
      gender = '??' if gender.blank?

      student_data[class_name] << ({
          :name => student_name + ' (' + gender + ')'.to_s,
          :marks => er.marks
        })
    end

    render :json => student_data.first and return
  end

  def capture_exam_results
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    exam_with_results_ids = '' if exam_with_results_ids.blank?
    @exams = Examination.find(:all, :conditions => ["exam_id NOT IN (?)", exam_with_results_ids])
    @class_rooms = [["[Select Class]", ""]]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.id]}
    @courses = [["[Select Course]", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}
    @exam_types = [["[Select Exam Type]", ""]]
    @exam_types += ExaminationType.all.collect{|et|[et.name, et.id]}
    @exams_with_results = Examination.find(:all, :conditions => ["exam_id IN (?)", exam_with_results_ids])
  end

  def edit_exam_results
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    @exams = Examination.find(:all, :conditions => ["exam_id IN (?)", exam_with_results_ids])
    @class_rooms = [["[Select Class]", ""]]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.id]}
    @courses = [["[Select Course]", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}
    @exam_types = [["[Select Exam Type]", ""]]
    @exam_types += ExaminationType.all.collect{|et|[et.name, et.id]}
    
  end

  def edit_exam_result_entry
    @exam = Examination.find(params[:exam_id])
    @students = @exam.students
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    exam_with_results_ids = '' if exam_with_results_ids.blank?
    @exams_with_results = Examination.find(:all, :conditions => ["exam_id IN (?)", exam_with_results_ids])
    if (request.method == :post)
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
      end

      flash[:notice] = "Operation successful"
      redirect_to :controller => "examination", :action => "edit_exam_results" and return
    end

    
  end
  
  def exam_result_entry
    @exam = Examination.find(params[:exam_id])
    @students = @exam.students

    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    exam_with_results_ids = '' if exam_with_results_ids.blank?
    @exams = Examination.find(:all, :conditions => ["exam_id NOT IN (?)", exam_with_results_ids])
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
    redirect_to :controller => "examination", :action => "capture_exam_results" and return
  end

  def void_exam_results
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    @exams = Examination.find(:all, :conditions => ["exam_id IN (?)", exam_with_results_ids])
    @class_rooms = [["---Select Class---", ""]]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.id]}
    @courses = [["---Select Course---", ""]]
    @courses += Course.all.collect{|c|[c.name, c.id]}
    @exam_types = [["---Select Exam Type---", ""]]
    @exam_types += ExaminationType.all.collect{|et|[et.name, et.id]}
    
  end

  def delete_exam_results
    if (params[:mode] == 'single_entry')
      exam = Examination.find(params[:exam_id])
      exam_results = exam.examination_results

      (exam_results || []).each do |er|
        examination_result = ExaminationResult.find(er.id)
        examination_result.delete
      end

      render :text => "true" and return
    end

    exam_ids = params[:exam_ids].split(",")

    (exam_ids || []).each do |exam_id|
      exam = Examination.find(exam_id)
      exam_results = exam.examination_results
      (exam_results || []).each do |er|
        examination_result = ExaminationResult.find(er.id)
        examination_result.delete
      end
    end

    render :text => "true" and return
  end

  def filter_exams
    class_room_ids = params[:class_room_id]
    if params[:class_room_id].blank?
      class_room_ids = ClassRoom.find(:all).map(&:id)
      class_room_ids = '0' if class_room_ids.blank?
    end
    course_ids = params[:course_id]
    if params[:course_id].blank?
      course_ids = Course.find(:all).map(&:id)
      course_ids = '0' if course_ids.blank?
    end
    exam_type_ids = params[:exam_type_id]
    if params[:exam_type_id].blank?
      exam_type_ids = ExaminationType.find(:all).map(&:id)
      exam_type_ids = '0' if exam_type_ids.blank?
    end
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    exam_with_results_ids = '0' if exam_with_results_ids.blank?
    
    examinations = Examination.find(:all, :conditions => ["class_room_id IN (?) AND
        exam_type_id IN (?) AND course_id IN (?) AND exam_id NOT IN (?)", class_room_ids,
        exam_type_ids, course_ids, exam_with_results_ids])

    hash = {}
    examinations.each do |examination|
      examination_id = examination.id
      class_room = examination.class_room.name
      exam_type = examination.examination_type.name
      course = examination.course.name
      exam_date = examination.start_date.to_date.strftime("%d/%b/%Y")
      exam_attendees = examination.students.count
      hash[examination_id] = {}
      hash[examination_id]["class_room"] = class_room
      hash[examination_id]["exam_type"] = exam_type
      hash[examination_id]["course"] = course
      hash[examination_id]["exam_date"] = exam_date
      hash[examination_id]["exam_attendees"] = exam_attendees
    end
    render :text => hash.to_json and return
  end

  def filter_exams_with_results
    class_room_ids = params[:class_room_id]
    if params[:class_room_id].blank?
      class_room_ids = ClassRoom.find(:all).map(&:id)
      class_room_ids = '0' if class_room_ids.blank?
    end
    course_ids = params[:course_id]
    if params[:course_id].blank?
      course_ids = Course.find(:all).map(&:id)
      course_ids = '0' if course_ids.blank?
    end
    exam_type_ids = params[:exam_type_id]
    if params[:exam_type_id].blank?
      exam_type_ids = ExaminationType.find(:all).map(&:id)
      exam_type_ids = '0' if exam_type_ids.blank?
    end
    exam_with_results_ids = ExaminationResult.find(:all).map(&:exam_id)
    exam_with_results_ids = '0' if exam_with_results_ids.blank?

    examinations = Examination.find(:all, :conditions => ["class_room_id IN (?) AND
        exam_type_id IN (?) AND course_id IN (?) AND exam_id IN (?)", class_room_ids,
        exam_type_ids, course_ids, exam_with_results_ids])

    hash = {}
    examinations.each do |examination|
      examination_id = examination.id
      class_room = examination.class_room.name
      exam_type = examination.examination_type.name
      course = examination.course.name
      exam_date = examination.start_date.to_date.strftime("%d/%b/%Y")
      exam_attendees = examination.students.count
      hash[examination_id] = {}
      hash[examination_id]["class_room"] = class_room
      hash[examination_id]["exam_type"] = exam_type
      hash[examination_id]["course"] = course
      hash[examination_id]["exam_date"] = exam_date
      hash[examination_id]["exam_attendees"] = exam_attendees
    end
    render :text => hash.to_json and return
  end
end
