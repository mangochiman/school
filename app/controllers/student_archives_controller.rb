class StudentArchivesController < ApplicationController
  before_filter :check_admin_role
  
  def archive_students
    if (params[:mode] == 'single_entry')
      StudentArchive.create({
          :student_id => params[:student_id],
          :reason => params[:archive_reason],
          :date_archived => Date.today
        })
      render :text => "true" and return
    end

    student_ids = params[:student_ids].split(",")
    (student_ids || []).each do |student_id|
      StudentArchive.create({
          :student_id => student_id,
          :reason => params[:archive_reason],
          :date_archived => Date.today
        })
    end

    render :text => "true" and return
  end

  def activate_archived_students
    if (params[:mode] == 'single_entry')
      student = Student.find(params[:student_id])
      student.student_archive.delete
      render :text => "true" and return
    end

    student_ids = params[:student_ids].split(",")
    (student_ids || []).each do |student_id|
      student = Student.find(student_id)
      student.student_archive.delete
    end

    render :text => "true" and return
  end
  
end
