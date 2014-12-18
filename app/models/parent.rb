class Parent < ActiveRecord::Base
    set_table_name :parent
    set_primary_key :parent_id

    has_one :student_parent, :foreign_key => :parent_id
end
