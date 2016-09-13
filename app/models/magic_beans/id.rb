module MagicBeans
	class Id < ActiveRecord::Base

		set_primary_key :id

		belongs_to :resource, polymorphic: true

	end
end