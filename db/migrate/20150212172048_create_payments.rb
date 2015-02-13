class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payment, :primary_key => :payment_id do |t|
      t.integer :student_id
      t.integer :payment_type_id
      t.integer :semester_id
      t.integer :amount_paid
      t.date :date
      t.timestamps
    end
  end

  def self.down
    drop_table :payment
  end
end
