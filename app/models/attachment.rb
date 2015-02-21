class Attachment < ActiveRecord::Base
  set_table_name :attachment
	set_primary_key :attachment_id

  belongs_to :attachment_type
end
