class ParentController < ApplicationController
  def index
    render :layout => false
  end

  def new_parent_guardian
    render :layout => false
  end
  
  def edit_parent_guardian
    @parents = Parent.all
    render :layout => false
  end
  
  def edit_me
    parent_id = params[:parent_id]
    @parent = Parent.find(parent_id)
    if request.method == :post
      if (@parent.update_attributes({
          :fname => params[:first_name],
          :lname => params[:last_name],
          :gender => params[:gender],
          :email => params[:email],
          :phone => params[:phone],
          :dob => params[:dob].to_date
        }))
        flash[:notice] = "You have successfully edited the details"
        redirect_to :controller => "parent", :action => "edit_parent_guardian" and return
      else
        flash[:error] = "Process aborted. Check for errors and try again"
        redirect_to :controller => "parent", :action => "edit_parent_guardian" and return
      end
    end
    render :layout => false
  end

  def void_parent_guardian
    render :layout => false
  end

  def create
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    email = params[:email]
    phone = params[:phone]
    date_of_birth = params[:dob].to_date
    if (Parent.create({
        :fname => first_name,
        :lname => last_name,
        :gender => gender,
        :email => email,
        :phone => phone,
        :dob => date_of_birth
      }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "parent", :action => "new_parent_guardian"
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "parent", :action => "new_parent_guardian"
    end
  end

  def search_parents
    first_name = params[:first_name]
    last_name = params[:last_name]
    gender = params[:gender]
    conditions = ""
    multiple = false
    unless first_name.blank?
      multiple = true
      conditions += "fname LIKE '%#{first_name}%'"
    end

    unless last_name.blank?
      multiple = true
      conditions += ' AND ' unless conditions.blank?
      conditions += "lname LIKE '%#{last_name}%' "
    end

    unless gender.blank?
      conditions += ' AND ' if multiple
      conditions += "gender = '#{gender}' "
    end

    unless conditions.blank?
      parents = Parent.find_by_sql("SELECT * FROM parent WHERE #{conditions}")
    else
      parents = Parent.all
    end

    hash = {}
    parents.each do |parent|
      parent_id = parent.id.to_s
      hash[parent_id] = {}
      hash[parent_id]["fname"] = parent.fname.to_s
      hash[parent_id]["lname"] = parent.lname.to_s
      hash[parent_id]["phone"] = parent.phone
      hash[parent_id]["email"] = parent.email
      hash[parent_id]["gender"] = parent.gender
      hash[parent_id]["dob"] = parent.dob.to_date.strftime("%d-%b-%Y")
      hash[parent_id]["join_date"] = parent.created_at.to_date.strftime("%d-%b-%Y")
    end
    render :json => hash and return
  end
  
end
