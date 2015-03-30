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

  def update_class_block
    block_name = params[:block_name]
    min_capacity = params[:min_capacity]
    max_capacity = params[:max_capacity]
    class_block = ClassBlock.find(params[:class_block_id])
    block_exists = ClassBlock.find(:first, :conditions => ["name =? AND class_block_id != ?",
        block_name, params[:class_block_id]])
    if block_exists
      flash[:error] = "Operation aborted.  <b>#{block_name}</b> already exists"
      redirect_to :controller => "class_blocks", :action => "edit_me", :class_block_id => params[:class_block_id] and return
    end
    class_block.update_attributes({
        :name => block_name,
        :min_carrying_capacity => min_capacity,
        :max_carrying_capacity => max_capacity
      })
    flash[:notice] = "Operation successful"
    redirect_to :controller => "class_blocks", :action => "add_class_block" and return
  end
  
  def void_class_block
    @class_blocks = ClassBlock.all
  end

  def view_class_blocks
    @class_blocks = ClassBlock.all
  end

  def delete_class_blocks
    if (params[:mode] == 'single_entry')
      class_block = ClassBlock.find(params[:class_block_id])
      class_block.delete
      render :text => "true" and return
    end

    class_block_ids = params[:class_block_ids].split(",")
    (class_block_ids || []).each do |class_block_id|
      class_block = ClassBlock.find(class_block_id)
      class_block.delete
    end
    render :text => "true" and return
  end

  def class_block_assignment
    @class_blocks = ClassBlock.all
  end

  def assign_me_class
    class_block_id = params[:class_block_id]
    @class_block = ClassBlock.find(class_block_id)
    @class_blocks = ClassBlock.all
    class_room_ids = @class_block.class_block_class_rooms.map(&:class_room_id)
    class_room_ids = '0' if class_room_ids.blank?
    @un_assigned_class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id NOT IN (?)",
        class_room_ids])
    @assigned_class_rooms = ClassRoom.find(:all, :conditions => ["class_room_id IN (?)",
        class_room_ids])
    @my_classes_count = @class_block.class_block_class_rooms.count
  end

  def assign_class_to_block
    class_block_id = params[:class_block_id]
    class_room_ids = params[:class_room_ids].split(",")
    class_room_ids.each do |class_room_id|
      ClassBlockClassRoom.create({
          :class_block_id => class_block_id,
          :class_room_id => class_room_id
        })
    end
    flash[:notice] = "Operation successful"
    redirect_to :controller => "class_blocks", :action => "assign_me_class", :class_block_id => class_block_id and return
  end

  def remove_class_block_class_room
    class_block_id = params[:class_block_id]
    class_room_id = params[:class_room_id]
    
    class_block_class_room = ClassBlockClassRoom.find(:first,
      :conditions => ["class_block_id =? AND class_room_id =?", class_block_id,
        class_room_id])
    class_block_class_room.delete
    class_block = ClassBlock.find(class_block_id)
    my_classes_count = class_block.class_block_class_rooms.count
    render :text => my_classes_count.to_s and return
  end

  def class_bock_without_classes
    class_block_ids = ClassBlockClassRoom.find(:all).map(&:class_block_id)
    class_block_ids = '0' if class_block_ids.blank?
    @class_blocks_without_classes = ClassBlock.find(:all,
      :conditions => ["class_block_id NOT IN (?)", class_block_ids]
    )
    @class_blocks = ClassBlock.all
  end

  def classes_without_blocks
    class_room_ids = ClassBlockClassRoom.find(:all).map(&:class_room_id)
    class_room_ids = '0' if class_room_ids.blank?
    @classes_without_blocks = ClassRoom.find(:all, 
      :conditions => ["class_room_id NOT IN (?)", class_room_ids]
    )
    @class_blocks = ClassBlock.all
  end
  
end
