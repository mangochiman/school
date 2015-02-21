class AttachmentType < ActiveRecord::Base
  set_table_name :attachment_type
	set_primary_key :attachment_type_id

  has_many :attachments
end
