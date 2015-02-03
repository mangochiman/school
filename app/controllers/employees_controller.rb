class EmployeesController < ApplicationController
  def employee_registration_menu
    render :layout => false
  end
  
  def employee_management_menu
    render :layout => false
  end
  
  def position_management_menu
    render :layout => false
  end

  def employee_registration_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def employee_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def position_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false    
  end

  def add_position
    if (request.method == :post)

      if (Position.create({
              :name => params[:position_name]
            }))
        flash[:notice] = "Operation successful"
      else
        flash[:error] = "Unable to save. Check for errors and try again"
      end
      redirect_to :action => "add_position" and return
    end
    render :layout => false
  end

  def edit_position
    @positions = Position.all
    render :layout => false
  end

  def edit_me_position
    position_id = params[:position_id]
    @position = Position.find(position_id)
    if (request.method == :post)

      if (@position.update_attributes({
              :name => params[:position_name]
            }))
        flash[:notice] = "Operation successful"
      else
        flash[:error] = "Unable to save. Check for errors and try again"
      end
      redirect_to :action => "edit_position" and return
    end
    render :layout => false
  end
  
  def remove_positions
    @positions = Position.all
    render :layout => false
  end

  def view_positions
    render :layout => false
  end

  def delete_positions
    if (params[:mode] == 'single_entry')
      position = Position.find(params[:position_id])
      position.delete
      render :text => "true" and return
    end

    position_ids = params[:position_ids].split(",")
      (position_ids || []).each do |position_id|
       position = Position.find(position_id)
       position.delete
    end

    render :text => "true" and return
  end
end
