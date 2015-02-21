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

  def download_document
    render :layout => false
  end

  def delete_documents
    render :layout => false
  end

  def view_documents
    render :layout => false
  end
  
end
