module MagicBeans
	class Id < ActiveRecord::Base

		belongs_to :resource, polymorphic: true

	end
end