class DepartmentsController < ApplicationController
  
  def department_management_menu
  end

  def add_department
    @departments = Department.find(:all)
    @faculties = [["[Faculty]", ""]]
    @faculties += Faculty.find(:all).collect{|f|[f.name, f.id]}
  end

  def create_department
    if (Department.create({
            :faculty_id => params[:faculty_id],
            :name => params[:department_name],
            :code => params[:department_code]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "departments", :action => "add_department" and return
    else
      flash[:error]  = "Unable to save. Check for errors and try again"
      redirect_to :controller => "departments", :action => "add_department" and return
    end
  end
  
  def edit_department
    if params[:department_id]
      @department = Department.find(params[:department_id])
    end
    @departments = Department.find(:all)
    @faculties = [["[Faculty]", ""]]
    @faculties += Faculty.find(:all).collect{|f|[f.name, f.id]}

    if request.method == :post
      if (@department.update_attributes({
              :faculty_id => params[:faculty_id],
              :name => params[:department_name],
              :code => params[:department_code]
            }))
        flash[:notice] = "Operation successful"
        redirect_to :controller => "departments", :action => "add_department" and return
      else
        flash[:error]  = "Unable to save. Check for errors and try again"
        redirect_to :controller => "departments", :action => "add_department" and return
      end
    end
  end

  def void_departments
    @departments = Department.find(:all)
  end

  def view_department
    @departments = Department.find(:all)
    @faculties = [["[ALL]", "All"]]
    @faculties += Faculty.find(:all).collect{|f|[f.name, f.id]}
  end
  
  def delete_departments
    if (params[:mode] == 'single_entry')
      department = Department.find(params[:department_id])
      department.delete
      render :text => "true" and return
    end

    department_ids = params[:department_ids].split(",")
    (department_ids || []).each do |department_id|
      department = Department.find(department_id)
      department.delete
    end
    render :text => "true" and return
  end

  def render_departments_by_faculty
    faculty_ids = params[:faculty_id]
    if (params[:faculty_id].match(/ALL/i))
      faculty_ids = Faculty.find(:all).map(&:id)
    end
    departments = Department.find(:all, :conditions => ["faculty_id IN (?)", faculty_ids])
    hash = {}
    (departments || []).each do |department|
      department_id = department.id
      hash[department_id] = {}
      hash[department_id]["department_name"] = department.name
      hash[department_id]["department_code"] = department.code
      hash[department_id]["department_faculty"] = department.faculty.name
    end
    render :text => hash.to_json and return
  end
  
end
