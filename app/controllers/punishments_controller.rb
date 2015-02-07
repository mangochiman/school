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
    
    @select_tag = "<select id='teacher'><option value=''></option>"
    Teacher.all.each{|t|
      name = t.fname.to_s + ' ' + t.lname.to_s + '(' + t.gender.first.upcase.to_s + ')'
      option="<option value=#{t.teacher_id}>#{name}</option>"
      @select_tag += option
    }
    @select_tag += '</select>'
    
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
    render :layout => false
  end

  def view_punishment_types
    render :layout => false
  end
  
end
