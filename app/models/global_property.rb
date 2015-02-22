class GlobalProperty < ActiveRecord::Base
  set_table_name "global_property"
  set_primary_key "global_property_id"

  def uploaded_file=(incoming_file)
    self.data = incoming_file.read
  end
end
