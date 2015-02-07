class PunishmentsController < ApplicationController
  def behavior_management_menu
    render :layout => false
  end
  
  def behavior_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def add_punishment
    @students = Student.all
    
    @teachers_select_tag = "<select id='teacher'><option value=''></option>"
    Teacher.all.each{|t|
      name = t.fname.to_s + ' ' + t.lname.to_s + '(' + t.gender.first.upcase.to_s + ')'
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
    
    render :layout => false
  end

  def edit_punishment
    render :layout => false
  end

  def remove_punishments
    render :layout => false
  end

  def view_punishments
    render :layout => false
  end

  def punishment_types_menu
    render :layout => false
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
    render :layout => false
  end
  
  def edit_punishment_type
    @punishment_types = PunishmentType.all
    render :layout => false
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
    
    render :layout => false
  end

  def remove_punishment_types
    @punishment_types = PunishmentType.all
    render :layout => false
  end

  def view_punishment_types
    @punishment_types = PunishmentType.all
    render :layout => false
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
      
    if (params[:mode] == 'single_entry')
      Punishment.create({
          :student_id => params[:student_id],
          :teacher_id => teacher_id,
          :punishment_type_id => punishment_type_id,
          :start_date => start_date,
          :end_date => end_date,
          :details => punishment_details,
          :completed => 0
        })
      render :text => "true" and return
    end

    student_ids = params[:student_ids].split(",")
    (student_ids || []).each do |student_id|
      Punishment.create({
          :student_id => student_id,
          :teacher_id => teacher_id,
          :punishment_type_id => punishment_type_id,
          :start_date => start_date,
          :end_date => end_date,
          :details => punishment_details,
          :completed => 0
        })
    end
    
    render :text => "true" and return
  end
end
