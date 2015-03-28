class ClassBlocksController < ApplicationController

  def add_class_block
    @class_blocks = ClassBlock.all
  end

  def create_class_block
    block_name = params[:block_name]
    min_capacity = params[:min_capacity]
    max_capacity = params[:max_capacity]
    block_exists = ClassBlock.find_by_name(block_name)
    if block_exists
      flash[:error] = "Operation aborted. Block already exists"
      redirect_to :controller => "class_blocks", :action => "add_class_block" and return
    end
    if(ClassBlock.create({
            :name => block_name,
            :min_carrying_capacity => min_capacity,
            :max_carrying_capacity => max_capacity
          }))

      flash[:notice] = "Operation successful"
      redirect_to :controller => "class_blocks", :action => "add_class_block" and return
    else
      flash[:error] = "Operation aborted. Check for errors and try again"
      redirect_to :controller => "class_blocks", :action => "add_class_block" and return
    end
  end
  
  def edit_class_block
    @class_blocks = ClassBlock.all
  end

  def edit_me
    @class_block = ClassBlock.find(params[:class_block_id])
    @class_blocks = ClassBlock.all
  end
  
  def void_class_block
    @class_blocks = ClassBlock.all
  end

  def view_class_blocks
    
  end
  
end
