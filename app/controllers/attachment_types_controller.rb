class AttachmentTypesController < ApplicationController

  def document_types_menu
    render :layout => false
  end
  
  def new_document_type
    @attachment_types = AttachmentType.find(:all)
    render :layout => false
  end

  def create
    document_type_exists = AttachmentType.find_by_name(params[:document_type_name])

    if document_type_exists
      flash[:error] = "Unable to save. Document Type already exists"
      redirect_to :controller => "attachment_types", :action => "new_document_type" and return
    end

    if (AttachmentType.create({
            :name => params[:document_type_name]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "attachment_types", :action => "new_document_type" and return
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "attachment_types", :action => "new_document_type" and return
    end
  end
  
  def edit_me
    attachment_type_id = params[:attachment_type_id]
    @attachment_type = AttachmentType.find(attachment_type_id)
    @attachment_types = AttachmentType.find(:all)
    
    if (request.method == :post)
      if (@attachment_type.update_attributes({
              :name => params[:document_type_name]
            }))
        flash[:notice] = "Operation successful"
        redirect_to :controller => "attachment_types", :action => "new_document_type" and return
      else
        flash[:error] = "Unable to save. Check for errors and try again"
        redirect_to :controller => "attachment_types", :action => "edit_me", :attachment_type_id => params[:attachment_type_id] and return
      end
    end
    
    render :layout => false
  end
  
  def edit_document_type
    @attachment_types = AttachmentType.find(:all)
    render :layout => false
  end

  def void_document_types
    @attachment_types = AttachmentType.find(:all)
    render :layout => false
  end

  def view_document_types
    @attachment_types = AttachmentType.find(:all)
    render :layout => false
  end

  def delete_attachment_types
    if (params[:mode] == 'single_entry')
      attachment_type = AttachmentType.find(params[:attachment_type_id])
      attachment_type.delete
      render :text => "true" and return
    end

    attachment_type_ids = params[:attachment_type_ids].split(",")
    (attachment_type_ids || []).each do |attachment_type_id|
      attachment_type = AttachmentType.find(attachment_type_id)
      attachment_type.delete
    end
    render :text => "true" and return
  end
  
end
