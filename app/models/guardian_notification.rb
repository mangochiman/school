class GuardianNotification < ActiveRecord::Base
  set_table_name :guardian_notification
	set_primary_key :guardian_notification_id

  belongs_to :parent, :foreign_key => :guardian_id
end
