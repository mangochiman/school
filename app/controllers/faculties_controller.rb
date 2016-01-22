class FacultiesController < ApplicationController

  def faculties_menu
    @faculties = Faculty.find(:all)
  end

  def add_faculty
    @faculties = Faculty.find(:all)
  end

  def create_faculty
    faculty_exists = Faculty.find_by_name(params[:faculty_name])
    unless faculty_exists.blank?
      flash[:error]  = "Unable to save. Faculty of <b>#{params[:faculty_name]}</b> already exists"
      redirect_to :controller => "faculties", :action => "add_faculty" and return
    end
    if (Faculty.create({
            :name => params[:faculty_name]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "faculties", :action => "add_faculty" and return
    else
      flash[:error]  = "Unable to save. Check for errors and try again"
      redirect_to :controller => "faculties", :action => "add_faculty" and return
    end
  end

  def edit_faculty
    if params[:faculty_id]
      @faculty = Faculty.find(params[:faculty_id])
    end
    @faculties = Faculty.find(:all)
    if request.method == :post
      if (@faculty.update_attributes({
              :name => params[:faculty_name]
            }))
        flash[:notice] = "Operation successful"
        redirect_to :controller => "faculties", :action => "add_faculty" and return
      else
        flash[:error]  = "Unable to save. Check for errors and try again"
        redirect_to :controller => "faculties", :action => "add_faculty" and return
      end
    end
  end

  def void_faculty
    @faculties = Faculty.find(:all)
  end

  def view_faculty
    @faculties = Faculty.find(:all)
  end

  def delete_faculties
    if (params[:mode] == 'single_entry')
      faculty = Faculty.find(params[:faculty_id])
      faculty.delete
      render :text => "true" and return
    end

    faculty_ids = params[:faculty_ids].split(",")
    (faculty_ids || []).each do |faculty_id|
      faculty = Faculty.find(faculty_id)
      faculty.delete
    end
    render :text => "true" and return
  end
end
