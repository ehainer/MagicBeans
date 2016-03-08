module MagicBeans
	class Config

		attr_accessor :icon_path, :svg_build_environment, :svg_fallback_directory, :logger

		def initialize
			@icon_path ||= Rails.root.join("app", "assets", "icons")
			@svg_build_environment ||= "development"
			@svg_fallback_directory = @icon_path
			@logger ||= Logger.new("magic_beans.log")
		end
	end
end
