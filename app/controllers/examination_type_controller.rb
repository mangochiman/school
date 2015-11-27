class ExaminationTypeController < ApplicationController
  def manage_exam_type_menu
    
  end
  
  def new_exam_type
    @exam_types = ExaminationType.find(:all)
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
    @exam_types = ExaminationType.find(:all)
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

  def void_exam_type
    @exam_types = ExaminationType.all
    
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

  def view_exam_types
    @exam_types = ExaminationType.all
    
  end

  def manage_exam_type_dashboard
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

  def search_examination_types
    exam_type_name = params[:exam_type_name]
    hash = {}
    exam_types = ExaminationType.find_by_sql("SELECT * FROM exam_type WHERE name LIKE '%#{exam_type_name}%'")

    exam_types.each do |exam_type|
      exam_type_id = exam_type.exam_type_id
      hash[exam_type_id] = {}
      hash[exam_type_id]["exam_type_name"] = exam_type.name.titleize
      hash[exam_type_id]["date_created"] = exam_type.created_at.to_date.strftime("%d-%b-%Y")
    end

    render :json => hash
  end
  
end
