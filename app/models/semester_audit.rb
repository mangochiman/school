class SemesterAudit < ActiveRecord::Base
  set_table_name :semester_audit
  set_primary_key :semester_audit_id
  
  belongs_to :semester, :foreign_key => :semester_id

  def self.set_current_semester(semester_id)
 
    selected_semester = self.find(:last, :conditions => ["semester_id =?", semester_id])
    start_date = selected_semester.start_date
    end_date = selected_semester.end_date

    #Close all open semesters if any
    self.close_open_semesters
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
  
end
