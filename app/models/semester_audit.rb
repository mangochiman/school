class SemesterAudit < ActiveRecord::Base
  set_table_name :semester_audit
  set_primary_key :semester_audit_id
  
  belongs_to :semester, :foreign_key => :semester_id

  def self.set_current_semester(semester_id)
 
    selected_semester = self.find(:last, :conditions => ["semester_id =?", semester_id])
    start_date = selected_semester.start_date
    end_date = selected_semester.end_date

    #Close all open semesters if any
    self.close_open_semesters #Normally one semester will be open
    semester = Semester.find(semester_id)
    semester.semester_audits.create({
        :start_date => start_date,
        :end_date => end_date,
        :state => "open"
      })
    
  end

  def self.close_open_semesters
    
    open_semesters = self.find(:all, :conditions => ["state =? ", 'open'])
    open_semesters.each do |semester|
      semester.state = 'close'
      semester.save
    end

  end

  def self.close_new_semesters

    new_semesters = self.find(:all, :conditions => ["state =? ", 'new'])
    new_semesters.each do |semester|
      semester.state = 'close'
      semester.save
    end

  end

  def self.initial_semester(semester_id, start_date, end_date)
    semester_audit = self.new
    semester_audit.semester_id = semester_id
    semester_audit.start_date = start_date
    semester_audit.end_date = end_date
    semester_audit.state = 'initial'
    semester_audit.save
  end

  def self.new_semester(semester_id, start_date, end_date)
    semester_audit = self.new
    semester_audit.semester_id = semester_id
    semester_audit.start_date = start_date
    semester_audit.end_date = end_date
    semester_audit.state = 'new'
    semester_audit.save
  end

  def self.new_academic_year
    old_semesters = self.find(:all, :conditions => ["state IN (?) ", ['new', 'open']])
    old_semesters.each do |semester|
      semester.state = 'close'
      semester.save
    end #Close old semesters

    Semester.all.each do |s|
      semester_id = s.semester_id
      semester_audit = self.new
      semester_audit.semester_id = semester_id
      semester_audit.start_date = '' #Start Date not yet added
      semester_audit.end_date = '' #End Date not yet added
      semester_audit.state = 'new'
      semester_audit.save
    end #Open new semesters

  end
  
end
