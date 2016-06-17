module MagicBeans
	class Config
		class Locale

			attr_accessor :build_environment, :enabled, :locales

			def initialize
				@build_environment ||= [:development]
				@enabled ||= true
				@locales ||= [:en]
			end

			def enabled?
				enabled == true
			end
		end
	end
end