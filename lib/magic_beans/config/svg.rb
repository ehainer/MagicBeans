module MagicBeans
	class Config
		class Svg

			attr_accessor :build_environment, :fallback_directory, :icon_directory

			def initialize
				@build_environment ||= [:development]
				@icon_directory ||= Rails.root.join("app", "assets", "icons")
				@fallback_directory ||= Rails.root.join("app", "assets", "images")
			end

			def is_buildable?
				# Always allow building of svg's -> images if running in the context of rake "precompiling"
				return true if File.basename($0) == "rake"

				@build_environment = [@build_environment] unless @build_environment.is_a?(Array)
				@build_environment.flatten!
				@build_environment.map!(&:to_s)
				@build_environment.include?(Rails.env.to_s)
			end
		end
	end
end
