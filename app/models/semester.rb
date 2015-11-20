class Semester < ActiveRecord::Base
  set_table_name :semesters
	set_primary_key :semester_id

  has_many :semester_audits, :foreign_key => :semester_id

  def self.create_new_semester(semester)
    Semester.create({:semester_number => semester})
  end
  
  def start_date
    open_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'open'])
    return open_semester.start_date unless open_semester.blank?

    new_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'new'])
    return new_semester.start_date unless new_semester.blank?

    initial_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'initial'])
    return initial_semester.start_date unless initial_semester.blank?
    
    return 'Unknown'
  end

  def end_date
    open_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'open'])
    return open_semester.end_date unless open_semester.blank?

    new_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'new'])
    return new_semester.end_date unless new_semester.blank?

    initial_semester = self.semester_audits.find(:last, :conditions => ["state =?", 'initial'])
    return initial_semester.end_date unless initial_semester.blank?

    return 'Unknown'
  end

  def self.current_active_semester_audit
    open_semester = SemesterAudit.find(:last, :conditions => ["state =?", 'open'])
    return open_semester unless open_semester.blank?
    return "" #No current active semester
  end

  def self.current_semester_number
    open_semester = SemesterAudit.find(:last, :conditions => ["state =?", 'open'])
    return open_semester.semester.semester_number unless open_semester.blank?
    return "" #No current active semester
  end

end
