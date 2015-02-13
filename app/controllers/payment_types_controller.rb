class PaymentTypesController < ApplicationController

  def payment_types_menu
    render :layout => false
  end

  def payment_types_management_dashboard
    render :layout => false
  end

  def add_payment_type
    @payment_types = PaymentType.find(:all)
    render :layout => false
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
  
  def edit_payment_type
    render :layout => false
  end

  def void_payment_types
    render :layout => false
  end

  def view_payment_types
    render :layout => false
  end
  
end
