module MagicBeans
	class Config
		class Crypt

			attr_accessor :offset, :seed, :blacklist

			def initialize
				@offset ||= 64
				@seed ||= nil
				@blacklist ||= Rails.root.join("config", "locales", "blacklist.txt")
			end
		end
	end
end