module MagicBeans
	class Config
		class Svg

			attr_accessor :build_environment, :fallback_directory, :icon_directory

			def initialize
				@build_environment ||= [:development]
				@icon_directory ||= Rails.root.join("app", "assets", "icons")
				@fallback_directory ||= Rails.root.join("app", "assets", "images")
			end
		end
	end
end
