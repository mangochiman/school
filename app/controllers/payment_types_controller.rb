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
    
  render :layout => false
end
  
def edit_payment_type
  @payment_types = PaymentType.find(:all)
  render :layout => false
end

def void_payment_types
  render :layout => false
end

def view_payment_types
  render :layout => false
end
  
end
