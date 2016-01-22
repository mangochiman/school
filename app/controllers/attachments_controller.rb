class AttachmentsController < ApplicationController

  def documents_management_dashboard
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

  def documents_management_menu
    @attachments_hash = {}
    @attachment_types_hash = {}

    (AttachmentType.all || []).each do |attachment_type|
      @attachment_types_hash[attachment_type.attachment_type_id] = attachment_type.name
    end

    (AttachmentType.all || []).each do |attachment_type|
      attachment_type_id = attachment_type.attachment_type_id
      @attachments_hash[attachment_type_id] = {} if @attachments_hash[attachment_type_id].blank?
      
      (attachment_type.attachments || []).each do |attachment|
        attachment_id = attachment.attachment_id
        @attachments_hash[attachment_type_id][attachment_id] = {}
        @attachments_hash[attachment_type_id][attachment_id]["file_name"] = attachment.filename
        @attachments_hash[attachment_type_id][attachment_id]["content_type"] = attachment.content_type
        @attachments_hash[attachment_type_id][attachment_id]["date_uploaded"] = attachment.created_at.to_date.strftime("%d-%b-%Y")
      
      end
      
    end
    
  end
  
  def upload_document
    @attachment_types = AttachmentType.find(:all)
    @attachment_select = [["[Document Type]", ""]]
    @attachment_select += AttachmentType.find(:all).collect{|a|[a.name, a.id]}
    
  end

  def create_attachment
    return if params[:attachment].blank?
    attachment = Attachment.new
    attachment.uploaded_file = params[:attachment]
    attachment.attachment_type_id = params[:document_type]
    if attachment.save
      flash[:notice] = "You have successfully uploaded your file"
      redirect_to :controller => :attachments, :action => :upload_document and return
    else
      flash[:error] = "There was a problem submitting your attachment. Check for errors and try again"
      redirect_to :controller => :attachments, :action => :upload_document and return
    end
  end
  
  def download_document
    unless params[:attachment_type_id].blank?
      @attachment_type = AttachmentType.find(params[:attachment_type_id])
    end
    @attachment_types = AttachmentType.find(:all)
    
  end

  def delete_documents
    unless params[:attachment_type_id].blank?
      @attachment_type = AttachmentType.find(params[:attachment_type_id])
    end
    @attachment_types = AttachmentType.find(:all)
    
  end

  def view_documents
    unless params[:attachment_type_id].blank?
      @attachment_type = AttachmentType.find(params[:attachment_type_id])
    end
    @attachment_types = AttachmentType.find(:all)
    
  end

  def view_raw_file
    @attachment = Attachment.find(params[:attachment_id])
    
  end

  def code_attachment
    @attachment = Attachment.find(params[:attachment_id])
    send_data @attachment.data, :filename => @attachment. filename, :type => @attachment.content_type, :disposition => "inline"
  end

  def delete_attachments
    if (params[:mode] == 'single_entry')
      attachment = Attachment.find(params[:attachment_id])
      attachment.delete
      render :text => "true" and return
    end

    attachment_ids = params[:attachment_ids].split(",")
    (attachment_ids || []).each do |attachment_id|
      attachment = Attachment.find(attachment_id)
      attachment.delete
    end
    render :text => "true" and return
  end

  def download_attachments
    if (params[:mode] == 'single_entry')
      attachment = Attachment.find(params[:attachment_id])
      send_data attachment.data, :filename => attachment. filename, :type => attachment.content_type, :disposition => "attachment" and return
      #render :text => "true" and return
    end

    attachment_ids = params[:attachment_ids].split(",")
    (attachment_ids || []).each do |attachment_id|
      attachment = Attachment.find(attachment_id)
      attachment.delete
    end
    render :text => "true" and return
  end

  def file_download
    attachment = Attachment.find(params[:attachment_id])
    send_data attachment.data, :filename => attachment. filename, :type => attachment.content_type, :disposition => "attachment" and return
  end
end
