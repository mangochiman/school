class PunishmentsController < ApplicationController
  before_filter :check_admin_role
  
  def behavior_management_menu
    @student_punishments_data = []
    students = Student.find_by_sql("SELECT s.* FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id LEFT JOIN student_archive sa
          ON s.student_id = sa.student_id WHERE scra.status = 'active' AND sa.student_id IS NULL")
    student_ids = students.map(&:student_id).join(', ')
    student_ids = '0' if student_ids.blank?
    
    top_ten_students_punishments = StudentPunishment.find_by_sql("SELECT COUNT(sp.student_id) as total_punishments,
         sp.student_id as student_id FROM student_punishment sp WHERE sp.student_id IN (#{student_ids})
         GROUP BY sp.student_id ORDER BY total_punishments DESC LIMIT 10")

    top_ten_students_punishments.each do |row|
      student_id = row.student_id
      student = Student.find(student_id)
      total_punishments = row.total_punishments
      student_name = student.name
      gender = student.gender
      mobile = student.mobile
      @student_punishments_data << [student_id, student_name, gender, mobile, total_punishments]
    end
  end
  
  def behavior_management_dashboard
    current_semester_audit = Semester.current_active_semester_audit
    semester_audit_id = current_semester_audit.semester_audit_id unless current_semester_audit.blank?
    semester_audit_id = SemesterAudit.last.semester_audit_id if current_semester_audit.blank?
    @current_semester_audit_id = (semester_audit_id rescue 0)
    
    @semester_data = SemesterAudit.formatted_semester_details(semester_audit_id)
    @males = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'MALE'").count

    @females = Student.find_by_sql("SELECT * FROM student s INNER JOIN student_class_room_adjustment scra ON
          s.student_id = scra.student_id WHERE scra.semester_audit_id = #{semester_audit_id}
          AND s.gender = 'FEMALE'").count
    
  end

  def add_punishment

    @students = Student.find_by_sql("SELECT s.* FROM student s LEFT JOIN student_archive sa
      ON s.student_id = sa.student_id WHERE sa.student_id IS NULL
      GROUP BY s.student_id")

    @teachers_select_tag = "<select id='teacher'><option value=''></option>"
    (Teacher.all || []).each{|t|
      name = t.fname.to_s + ' ' + t.lname.to_s + '(' + (t.gender.first.upcase.to_s rescue 'Unknown') + ')'
      option="<option value=#{t.teacher_id}>#{name}</option>"
      @teachers_select_tag += option
    }
    @teachers_select_tag += '</select>'

    @punishment_types_select_tag = "<select id='punishment_type_select'><option value=''></option>"
    PunishmentType.all.each{|pt|
      option="<option value=#{pt.punishment_type_id}>#{pt.name}</option>"
      @punishment_types_select_tag += option
    }
    @punishment_types_select_tag += '</select>'
    
    
  end

  def edit_punishment
    @punishments = Punishment.find(:all)
    @punishment_types = PunishmentType.all

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
  end

  def edit_me_punishment
    @punishment = Punishment.find(params[:punishment_id])
    @teachers_select_tag = "<select id='teacher' name='teacher' class='select required'><option value=''></option>"
    Teacher.all.each{|t|
      name = t.fname.to_s + ' ' + t.lname.to_s + '(' + (t.gender.first.upcase.to_s rescue '?') + ')'
      option="<option value=#{t.teacher_id}>#{name}</option>"
      @teachers_select_tag += option
    }
    @teachers_select_tag += '</select>'

    @punishment_types_select_tag = "<select id='punishment_type' name = 'punishment_type' class='select required'><option value=''></option>"
    PunishmentType.all.each{|pt|
      option="<option value=#{pt.punishment_type_id}>#{pt.name}</option>"
      @punishment_types_select_tag += option
    }
    @punishment_types_select_tag += '</select>'

    if (request.method == :post)
      punishment_type_id = params[:punishment_type]
      teacher_id = params[:teacher]
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
        redirect_to :action => "edit_punishment" and return
      else
        flash[:error] = "Unable to save. Check for errors and try again"
        redirect_to :action => "edit_punishment" and return
      end
    end
    
    
  end
  
  def remove_punishments
    @punishments = Punishment.find_by_sql("SELECT p.* FROM punishment p
      INNER JOIN punishment_type pt ON p.punishment_id = pt.punishment_type_id
      INNER JOIN student_punishment sp ON p.punishment_id = sp.punishment_id
      INNER JOIN student s ON sp.student_id = s.student_id
      LEFT JOIN student_archive sa ON s.student_id = sa.student_id WHERE sa.student_id IS NULL
      GROUP BY p.punishment_id")
    @punishment_types = PunishmentType.all

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
  end

  def view_punishments
    @punishments = Punishment.find_by_sql("SELECT p.* FROM punishment p
      INNER JOIN punishment_type pt ON p.punishment_id = pt.punishment_type_id
      INNER JOIN student_punishment sp ON p.punishment_id = sp.punishment_id
      INNER JOIN student s ON sp.student_id = s.student_id
      LEFT JOIN student_archive sa ON s.student_id = sa.student_id WHERE sa.student_id IS NULL
      GROUP BY p.punishment_id")
    @punishment_types = PunishmentType.all

    @class_rooms = ["All"]
    @class_rooms += ClassRoom.all.collect{|cr|[cr.name, cr.class_room_id]}
  end

  def punishment_types_menu
    @punishment_types = PunishmentType.all
  end

  def add_punishment_type
    if (request.method == :post)
      punishment_type = params[:punishment_type]
      if (PunishmentType.create({:name => punishment_type}))
        flash[:notice] = "Operation successful"
        redirect_to :action => "add_punishment_type" and return
      else
        flash[:error] = "Unable to save. Check for errors and try again"
        render  :action => "add_punishment_type" and return
      end
    end
    
  end
  
  def edit_punishment_type
    @punishment_types = PunishmentType.all
    
  end

  def edit_me_punishment_type
    punishment_type_id = params[:punishment_type_id]
    @punishment_type = PunishmentType.find(punishment_type_id)

    if (request.method == :post)
      if (@punishment_type.update_attributes({:name => params[:punishment_type]}))
        flash[:notice] = "Operation successful"
        redirect_to :action => "edit_punishment_type" and return
      else
        render :action => "edit_me_punishment_type", :punishment_type_id => params[:punishment_type] and return
      end
    end
    
    
  end

  def remove_punishment_types
    @punishment_types = PunishmentType.all
    
  end

  def view_punishment_types
    @punishment_types = PunishmentType.all
    
  end

  def delete_punishment_types
    if (params[:mode] == 'single_entry')
      punishment_type = PunishmentType.find(params[:punishment_type_id])
      punishment_type.delete
      render :text => "true" and return
    end

    punishment_type_ids = params[:punishment_type_ids].split(",")
    (punishment_type_ids || []).each do |punishment_type_id|
      punishment_type = PunishmentType.find(punishment_type_id)
      punishment_type.delete
    end

    render :text => "true" and return
  end

  def punish_students
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
      
    if (params[:mode] == 'single_entry')
      StudentPunishment.create({
          :student_id => params[:student_id],
          :punishment_id => punishment.punishment_id,
          :completed => 0
        })
      render :text => "true" and return
    end

    student_ids = params[:student_ids].split(",")
    (student_ids || []).each do |student_id|
      StudentPunishment.create({
          :student_id => student_id,
          :punishment_id => punishment.punishment_id,
          :completed => 0
        })
    end
    
    render :text => "true" and return
  end

  def delete_punishments
    if (params[:mode] == 'single_entry')
      punishment = Punishment.find(params[:punishment_id])
      students_punishments = StudentPunishment.find(:all, :conditions => ["punishment_id =?",
          punishment.id])
      (students_punishments || []).each do |sp|
        sp.delete
      end
      punishment.delete
      render :text => "true" and return
    end

    punishment_ids = params[:punishment_ids].split(",")
    (punishment_ids || []).each do |punishment_id|
      punishment = Punishment.find(punishment_id)
      students_punishments = StudentPunishment.find(:all, :conditions => ["punishment_id =?", punishment.id])
      (students_punishments || []).each do |sp|
        sp.delete
      end
      punishment.delete
    end

    render :text => "true" and return
  end

  def punishment_students_edit
    punishment_id = params[:punishment_id]
    @punishment_students = StudentPunishment.find(:all, :conditions => ["punishment_id =?", punishment_id])
    
  end

  def student_punishment_delete
    student_id = params[:student_id]
    punishment_id = params[:punishment_id]
    student_punishment = StudentPunishment.find(:last, :conditions => ["student_id =? AND 
        punishment_id =?", student_id, punishment_id])
    student_punishment.delete
    render :text => true and return
  end

  def show_student_punishments
    student_id = params[:student_id]
    @student_punishments = StudentPunishment.find(:all, :conditions => ["student_id =?", student_id])
    
  end

  def search_punishments
    punishment_type_id = params[:punishment_type_id]
    class_room_id = params[:class_room_id]
    
    (class_room_id = ClassRoom.all.map(&:id).join(', ')) if (class_room_id.blank?)

    oder_by = params[:oder_by]
    field = oder_by.split(/\W+/)[0]
    asc_or_desc = oder_by.split(/\W+/)[1]
    limit = params[:limit]

    if (params[:punishment_type_id].match(/ALL/i))
      punishment_type_id = PunishmentType.all.map(&:id).join(', ')
      punishment_type_id = 0 if punishment_type_id.blank?
    end

    hash = {}
    punishments = Punishment.find_by_sql("SELECT p.* FROM punishment p
      INNER JOIN punishment_type pt ON p.punishment_id = pt.punishment_type_id AND
      pt.punishment_type_id IN (#{punishment_type_id})
      INNER JOIN student_punishment sp ON p.punishment_id = sp.punishment_id
      INNER JOIN student s ON sp.student_id = s.student_id
      INNER JOIN student_class_room_adjustment scra ON s.student_id = scra.student_id
      LEFT JOIN student_archive sa ON s.student_id = sa.student_id WHERE sa.student_id IS NULL
      AND scra.new_class_room_id IN (#{class_room_id})
      GROUP BY p.punishment_id ORDER BY DATE(p.#{field}) #{asc_or_desc} LIMIT #{limit}")
    
    punishments.each do |punishment|
      punishment_id = punishment.id.to_s
      hash[punishment_id] = {}
      hash[punishment_id]["punishment_type"] = punishment.punishment_type.name
      hash[punishment_id]["punishment_details"] = punishment.details
      hash[punishment_id]["responsible_teacher"] = punishment.teacher.fname + ' ' + punishment.teacher.lname
      hash[punishment_id]["total_students"] = punishment.students.count
      hash[punishment_id]["start_date"] = punishment.start_date.to_date.strftime("%d-%b-%Y")
      hash[punishment_id]["end_date"] = punishment.end_date.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end

  def search_punishment_types
    punishment_type_name = params[:punishment_type_name]
    hash = {}
    punishment_types = PunishmentType.find_by_sql("SELECT * FROM punishment_type WHERE name LIKE '%#{punishment_type_name}%'")

    punishment_types.each do |punishment_type|
      punishment_type_id = punishment_type.punishment_type_id
      hash[punishment_type_id] = {}
      hash[punishment_type_id]["punishment_name"] = punishment_type.name
      hash[punishment_type_id]["date_created"] = punishment_type.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end
  
end
