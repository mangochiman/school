class PaymentTypesController < ApplicationController

  def payment_types_menu
    
  end

  def payment_types_management_dashboard
    
  end

  def add_payment_type
    @payment_types = PaymentType.find(:all)
    
  end

  def create
    if (PaymentType.create({
            :name => params[:payment_type],
            :amount_required => params[:amount_required]
          }))
      flash[:notice] = "Operation successful"
      redirect_to :controller => "payment_types", :action => "add_payment_type"
    else
      flash[:error] = "Unable to save. Check for errors and try again"
      render :controller => "payment_types", :action => "add_payment_type"
    end
  end

  def edit_me
    @payment_types = PaymentType.find(:all)
    @payment_type = PaymentType.find(params[:payment_type_id])
    
    if (request.method == :post)
      if (
          @payment_type.update_attributes({
              :name => params[:payment_type],
              :amount_required => params[:amount_required]
            })
        )
        flash[:notice] = "Operation succesful"
        redirect_to :controller => "payment_types", :action => "add_payment_type" and return
      else
        flash[:error] = "Unable to save. Check for errors and try again"
        redirect_to :controller => "payment_types", :action => "edit_me", :payment_type_id => params[:payment_type_id] and return
      end
    end
    
    
  end
  
  def edit_payment_type
    @payment_types = PaymentType.find(:all)
    
  end

  def void_payment_types
    @payment_types = PaymentType.find(:all)
    
  end

  def view_payment_types
    @payment_types = PaymentType.find(:all)
    
  end

  def delete_payment_types
    if (params[:mode] == 'single_entry')
      payment_type = PaymentType.find(params[:payment_type_id])
      payment_type.delete
      render :text => "true" and return
    end

    payment_type_ids = params[:payment_type_ids].split(",")
    (payment_type_ids || []).each do |payment_type_id|
      payment_type = PaymentType.find(payment_type_id)
      payment_type.delete
    end
    render :text => "true" and return
  end

  def search_payment_types
    payment_type_name = params[:payment_type_name]
    order_by = params[:order_by]
    order_by = 'amount_required ASC' if order_by.blank?

    if (order_by.match(/DESC/i))
      sort_direction = 'reverse'
    else
      sort_direction = 'forward'
    end

    hash = {}
    payment_types = PaymentType.find_by_sql("SELECT * FROM payment_type WHERE name LIKE '%#{payment_type_name}%' ORDER BY #{order_by}")

    payment_types.each do |payment_type|
      payment_type_id = payment_type.payment_type_id.to_s
      hash[payment_type_id] = {}
      hash[payment_type_id]["payment_type_name"] = payment_type.name
      hash[payment_type_id]["amount_set"] = ActionController::Base.helpers.number_to_currency(payment_type.amount_required, :unit => 'MK')
      hash[payment_type_id]["amount_not_formatted"] = payment_type.amount_required
      hash[payment_type_id]["date_created"] = payment_type.created_at.to_date.strftime("%d-%b-%Y")
    end
    raise Hash[hash.sort_by{|k, v|-v["amount_not_formatted"].to_i}].to_yaml
    if (sort_direction == 'reverse')
      #Hash[hash.sort_by{|k, v|v["amount_not_formatted"].to_i}.reverse] #Return back the hash after sorting. Hash sorting returns an array
      x = Hash[hash.sort_by{|k, v|-v["amount_not_formatted"].to_i}]
      raise x.to_yaml
    else
      hash = Hash[hash.sort_by{|k, v|-v["amount_not_formatted"].to_i}.reverse]
    end #This is because the hash by default is sorting by key in regardless of the order by query. Just a hack to do the order by manually

    raise hash.inspect
    render :json => hash and return
  end

end
