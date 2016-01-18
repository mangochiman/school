class Employee < ActiveRecord::Base
  set_table_name :employee
	set_primary_key :employee_id

  has_one :employee_position
  has_many :employee_statuses

  has_many :class_room_teachers, :foreign_key => :teacher_id
  has_many :teacher_class_room_courses, :foreign_key => :teacher_id

  def retire(start_date, end_date)
    employee_status = EmployeeStatus.new
    employee_status.employee_id = self.employee_id
    employee_status.status = 'Retired'
    employee_status.start_date = start_date
    employee_status.end_date = end_date
    employee_status.save!
  end

  def currently_retired?
    status = self.employee_statuses.find(:last, :conditions => ["status =?", 'Retired'])
    return true unless status.blank?
    return false
  end
  
  def suspend(start_date, end_date)
    employee_status = EmployeeStatus.new
    employee_status.employee_id = self.employee_id
    employee_status.status = 'Suspended'
    employee_status.start_date = start_date
    employee_status.end_date = end_date
    employee_status.save!
  end

  def currently_suspended?
    status = self.employee_statuses.find(:last, :conditions => ["status =? AND DATE(end_date) > ?", 
        'Suspended', Date.today])
    return true unless status.blank?
    return false
  end
  
  def stop(start_date, end_date)
    employee_status = EmployeeStatus.new
    employee_status.employee_id = self.employee_id
    employee_status.status = 'Stopped'
    employee_status.start_date = start_date
    employee_status.end_date = end_date
    employee_status.save!
  end

  def currently_stopped?
    status = self.employee_statuses.find(:last, :conditions => ["status =?", 'Stopped'])
    return true unless status.blank?
    return false
  end
  
  def end_contract(start_date, end_date)
    employee_status = EmployeeStatus.new
    employee_status.employee_id = self.employee_id
    employee_status.status = 'Contract Ended'
    employee_status.start_date = start_date
    employee_status.end_date = end_date
    employee_status.save!
  end

  def currently_ended_contract?
    status = self.employee_statuses.find(:last, :conditions => ["status =?", 'Contract Ended'])
    return true unless status.blank?
    return false
  end

  def name
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    first_name + ' ' + last_name
  end
  
  def name_and_gender
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    gender = self.gender.first.to_s rescue 'unknown'
    first_name + ' ' + last_name + ' (' + gender + ')'
  end

  def name_and_position
    first_name = self.fname.to_s rescue ''
    last_name = self.lname.to_s rescue ''
    position = self.employee_position.position.name rescue 'unknown'
    first_name + ' ' + last_name + ' (' + position + ')'
  end
end
