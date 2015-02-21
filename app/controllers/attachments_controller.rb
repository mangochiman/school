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

  def document_types_menu
    render :layout => false
  end
  
  def new_document_type
    render :layout => false
  end

  def edit_document_type
    render :layout => false
  end

  def void_document_types
    render :layout => false
  end

  def view_document_types
    render :layout => false
  end
  
end
