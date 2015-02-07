class PunishmentsController < ApplicationController
  def behavior_management_menu
    render :layout => false
  end
  
  def behavior_management_dashboard
    start_year = Date.today.year - 5
    end_year = Date.today.year
    @years = (start_year..end_year).to_a.reverse
    @males = Student.find_by_sql("SELECT * FROM student WHERE gender = 'MALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    @females = Student.find_by_sql("SELECT * FROM student WHERE gender = 'FEMALE' AND
          DATE_FORMAT(created_at, '%Y') = #{Date.today.year}").count
    render :layout => false
  end

  def add_punishment
    @students = Student.all
    render :layout => false
  end

  def edit_punishment
    render :layout => false
  end

  def remove_punishments
    render :layout => false
  end

  def view_punishments
    render :layout => false
  end
  
end
