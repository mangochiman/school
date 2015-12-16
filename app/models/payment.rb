class Payment < ActiveRecord::Base
  set_table_name :payment
  set_primary_key :payment_id

  belongs_to :payment_type, :foreign_key => "payment_type_id"
  belongs_to :student, :foreign_key => "student_id"
  before_save :add_defaults
  
  def add_defaults
    #semester_audit_id = Semester.current_active_semester_audit.semester_audit_id rescue ''
    #raise "Please set active semester first before proceeding. Operation Aborted".to_yaml if semester_audit_id.blank?
    #self.semester_audit_id = semester_audit_id
  end

  def self.new_payment(student_id, payment_type, amount_paid, date_paid, semester_id)
    Payment.create({
            :student_id => student_id,
            :payment_type_id => payment_type,
            :amount_paid => amount_paid,
            :date => date_paid,
            :semester_audit_id => semester_id
          })
  end
  
end
