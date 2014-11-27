class StudentController < ApplicationController
  def index
    render :layout => false
  end

  def my_results
    render :layout => false
  end
end
