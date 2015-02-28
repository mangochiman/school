class EmployeesController < ApplicationController
  def employee_registration_menu
    
  end
  
  def employee_management_menu
    
  end
  
  def position_management_menu
    
  end

  def employee_registration_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def employee_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    
  end

  def position_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
        
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
    
  end

  def edit_position
    @positions = Position.all
    
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
    
  end
  
  def remove_positions
    @positions = Position.all
    
  end

  def view_positions
    @positions = Position.all
    
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

  def add_employee
    @positions = [["[select Position]", ""]]
    @positions += Position.find(:all).collect{|p|[p.name, p.id]}
    @employees = Employee.find(:all)
    if (request.method == :post)
      first_name = params[:firstname]
      last_name = params[:lastname]
      gender = params[:gender]
      email = params[:email]
      phone = params[:phone]
      date_of_birth = params[:dob].to_date

      position_id = params[:position]
      ActiveRecord::Base.transaction do
        employee = Employee.new
        employee.fname = first_name
        employee.lname = last_name
        employee.gender = gender
        employee.email = email
        employee.phone = phone
        employee.dob = date_of_birth
        employee.save

        employ_position = EmployeePosition.new
        employ_position.employee_id = employee.id
        employ_position.position_id = position_id
        employ_position.save
      end
      
      flash[:notice] = "Operation successful"
      redirect_to :action => "add_employee" and return
    end
    
    
  end
  
  def edit_employee
    @employees = Employee.all
    
  end

  def edit_me_employee
    @positions = [["[select Position]", ""]]
    @positions += Position.find(:all).collect{|p|[p.name, p.id]}
    
    employee_id = params[:employee_id]
    @employee = Employee.find(employee_id)
    @my_position = @employee.employee_position.position
    @employees = Employee.find(:all)
    if (request.method == :post)

      ActiveRecord::Base.transaction do
        employee = Employee.find(employee_id)
        employee.update_attributes({
            :fname => params[:firstname],
            :lname => params[:lastname],
            :gender => params[:gender],
            :email => params[:email],
            :phone => params[:phone],
            :dob => params[:dob].to_date
          })

        employ_position = EmployeePosition.find_by_employee_id(employee_id)
        employ_position.delete #EmployPosition couldn't be updated. Needs to be Improved

        employ_position = EmployeePosition.new
        employ_position.employee_id = employee.id
        employ_position.position_id = params[:position]
        employ_position.save
      end

      flash[:notice] = "Operation successful"
      redirect_to :action => "edit_employee" and return
    end
    
  end
  
  def remove_employees
    @employees = Employee.all
    
  end

  def view_employees
    @employees = Employee.all
    
  end

  def delete_employees
    if (params[:mode] == 'single_entry')
      ActiveRecord::Base.transaction do
        employee = Employee.find(params[:employee_id])
        employee.delete
        employ_position = EmployeePosition.find_by_employee_id(params[:employee_id])
        employ_position.delete
      end
      render :text => "true" and return
    end

    employee_ids = params[:employee_ids].split(",")
    ActiveRecord::Base.transaction do
      (employee_ids || []).each do |employee_id|
        employee = Employee.find(employee_id)
        employee.delete
        employ_position = EmployeePosition.find_by_employee_id(employee_id)
        employ_position.delete
      end
    end
    render :text => "true" and return
  end

  def retire_employee
    @employees = []
    employees = Employee.all
    employees.each do |emp|
      next if emp.currently_retired?
      @employees << emp
    end
    
    if (request.method == :post)
      if (params[:mode] == 'single_entry')
        employee = Employee.find(params[:employee_id])
        employee.retire(params[:start_date], params[:end_date])
        render :text => "true" and return
      end

      employee_ids = params[:employee_ids].split(",")
      (employee_ids || []).each do |employee_id|
        employee = Employee.find(employee_id)
        employee.retire(params[:start_date], params[:end_date])
      end
      render :text => "true" and return
    end
    
    
  end

  def suspend_employee
    @employees = []
    employees = Employee.all
    employees.each do |emp|
      next if emp.currently_suspended?
      @employees << emp
    end

    if (request.method == :post)
      if (params[:mode] == 'single_entry')
        employee = Employee.find(params[:employee_id])
        employee.suspend(params[:start_date], params[:end_date])
        render :text => "true" and return
      end

      employee_ids = params[:employee_ids].split(",")
      (employee_ids || []).each do |employee_id|
        employee = Employee.find(employee_id)
        employee.suspend(params[:start_date], params[:end_date])
      end
      render :text => "true" and return
    end
    
    
  end

  def stop_employees
    @employees = []
    employees = Employee.all
    employees.each do |emp|
      next if emp.currently_stopped?
      @employees << emp
    end
    
    if (request.method == :post)
      if (params[:mode] == 'single_entry')
        employee = Employee.find(params[:employee_id])
        employee.stop(params[:start_date], params[:end_date])
        render :text => "true" and return
      end

      employee_ids = params[:employee_ids].split(",")
      (employee_ids || []).each do |employee_id|
        employee = Employee.find(employee_id)
        employee.stop(params[:start_date], params[:end_date])
      end
      render :text => "true" and return
    end
    
    
  end

  def end_contract
    @employees = []
    employees = Employee.all
    employees.each do |emp|
      next if emp.currently_ended_contract?
      @employees << emp
    end
    
    if (request.method == :post)
      if (params[:mode] == 'single_entry')
        employee = Employee.find(params[:employee_id])
        employee.end_contract(params[:start_date], params[:end_date])
        render :text => "true" and return
      end

      employee_ids = params[:employee_ids].split(",")
      (employee_ids || []).each do |employee_id|
        employee = Employee.find(employee_id)
        employee.end_contract(params[:start_date], params[:end_date])
      end
      render :text => "true" and return
    end

    
  end
  
end
