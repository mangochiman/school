class ClassRoomController < ApplicationController
  def index
    render :layout => false
  end

  def add_class
    render :layout => false
  end

  def edit_class
    @class_rooms = ClassRoom.all
    render :layout => false
  end

  def assign_subjects
    render :layout => false
  end

  def edit_subjects
    render :layout => false
  end

  def assign_teacher
    render :layout => false
  end

  def edit_teacher
    render :layout => false
  end

  def create_class_rooms
    class_name = params[:class_name]
    year = params[:year]
    grade = params[:grade]
    if (ClassRoom.create({
        :year => year,
        :grade => grade,
        :name => class_name
      }))
        flash[:notice] = "You have successfully created classroom"
        redirect_to :action => "add_class" and return
    else
      flash[:error] = "Operation not successful. Check for errors and try again"
      render :action => "add_class" and return
    end
  end
  
end
