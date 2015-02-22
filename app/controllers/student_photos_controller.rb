class StudentPhotosController < ApplicationController

  def upload_photo
    student_photo = StudentPhoto.new
    student_photo.uploaded_file = params[:webcam]
    student_photo.student_id = params[:student_id]
    if student_photo.save
      render :text => "success" and return
    else
      render :text => "error" and return
    end
  end

  def code_student_photo
    @student_photo = StudentPhoto.find(:last, :conditions => ["student_id =?", params[:student_id]])
    send_data @student_photo.data, :filename => @student_photo.filename, :type => @student_photo.content_type, :disposition => "inline"
  end

  def code_by_student_photo_id
    @student_photo = StudentPhoto.find(params[:student_photo_id])
    send_data @student_photo.data, :filename => @student_photo.filename, :type => @student_photo.content_type, :disposition => "inline"
  end

  def delete_photos
    student_photo = StudentPhoto.find(params[:student_photo_id])
    student_photo.delete
    render :text => "true and return"
  end
  
end
