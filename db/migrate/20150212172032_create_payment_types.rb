class CreatePaymentTypes < ActiveRecord::Migration
  def self.up
    create_table :payment_type, :primary_key => :payment_type_id do |t|
      t.string :name
      t.string :amount_required
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_type
  end
end
