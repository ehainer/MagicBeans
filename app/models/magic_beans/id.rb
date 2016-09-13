module MagicBeans
	class Id < ActiveRecord::Base

		self.primary_key = "id"

		belongs_to :resource, polymorphic: true

	end
end