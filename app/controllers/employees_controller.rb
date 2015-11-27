class EmployeesController < ApplicationController
  def employee_registration_menu
    
  end
  
  def employee_management_menu
    
  end
  
  def position_management_menu
    
  end

  def employee_registration_dashboard
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

  def employee_management_dashboard
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

  def position_management_dashboard
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

  def add_position
    @positions = Position.find(:all)
    if (request.method == :post)
      position_exists = Position.find_by_name(params[:position_name])
      if (position_exists)
        flash[:error] = "Unable to save. Position <b>#{params[:position_name]}</b> already exists"
        redirect_to :controller => "employees",:action => "add_position" and return
      end
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
    @positions = Position.all
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

  def render_employees
    fname = params[:first_name]
    lname = params[:last_name]
    gender = params[:gender]
    gender = ['Male', 'Female'] if params[:gender].blank?
    
    employees = Employee.find(:all, :conditions => ["fname LIKE (?) AND lname LIKE (?) AND
        gender IN (?)", '%' + fname + '%', '%' + lname + '%', gender])
    employees_hash = {}
    
    employees.each do |employee|
      employee_id = employee.id
      employees_hash[employee_id] = {}
      employees_hash[employee_id]['fname'] = employee.fname
      employees_hash[employee_id]['lname'] = employee.lname
      employees_hash[employee_id]['email'] = employee.email
      employees_hash[employee_id]['gender'] = employee.gender
      employees_hash[employee_id]['dob'] = employee.dob.to_date.strftime("%d-%b-%Y")
      employees_hash[employee_id]['phone'] = employee.phone
      employees_hash[employee_id]['position'] = employee.employee_position.position.name.titleize
    end

    render :text => employees_hash.to_json and return
  end

end
