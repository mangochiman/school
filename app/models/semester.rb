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

  def self.current_semester_start_date
    open_semester = SemesterAudit.find(:last, :conditions => ["state =?", 'open'])
    return open_semester.start_date unless open_semester.blank?
    return ""
  end

  def self.current_semester_end_date
    open_semester = SemesterAudit.find(:last, :conditions => ["state =?", 'open'])
    return open_semester.end_date unless open_semester.blank?
    return ""
  end

  def self.current
    semester = SemesterAudit.find(:last, :conditions => ["state =?", 'open']).semester rescue ''
    return semester
  end

  def self.create_new_semester_without_parameter
    semester_number = 0
    last_semester = Semester.last
    semester_number = last_semester.semester_number.to_i unless last_semester.blank?
    start_date = '' #Not Set AT This Time
    end_date = '' #Not Set AT This Time
    semester = Semester.create({:semester_number => semester_number + 1})
    SemesterAudit.initial_semester(semester.semester_id, start_date, end_date)
    SemesterAudit.new_semester(semester.semester_id, start_date, end_date)
    return semester
  end
  
end
