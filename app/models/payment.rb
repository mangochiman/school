class Payment < ActiveRecord::Base
  set_table_name :payment
  set_primary_key :payment_id

  belongs_to :payment_type, :foreign_key => "payment_type_id"
end
