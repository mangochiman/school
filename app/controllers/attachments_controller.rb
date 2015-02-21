class AttachmentsController < ApplicationController

  def documents_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def documents_management_menu
    render :layout => false
  end
  
  def upload_document
    @attachment_types = AttachmentType.find(:all)
    @attachment_select = [["[Document Type]", ""]]
    @attachment_select += AttachmentType.find(:all).collect{|a|[a.name, a.id]}
    render :layout => false
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
    render :layout => false
  end

  def delete_documents
    unless params[:attachment_type_id].blank?
      @attachment_type = AttachmentType.find(params[:attachment_type_id])
    end
    @attachment_types = AttachmentType.find(:all)
    render :layout => false
  end

  def view_documents
    render :layout => false
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
