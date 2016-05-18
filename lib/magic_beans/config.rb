require "sprockets"

module MagicBeans
	class Config

		attr_accessor :svg_build_environment, :svg_fallback_directory, :logger, :packages, :debug

		def initialize
			@custom = Hash.new
			@svg_build_environment ||= [:development]
			@svg_fallback_directory ||= Rails.root.join("app", "assets", "images")
			@logger ||= Logger.new("magic_beans.log")
			@debug ||= false
			@packages ||= []
		end

		def to_json
			{
				stylesheet: ActionController::Base.helpers.asset_path("tinymce.css"),
				packages: @packages,
				debug: @debug
			}.merge(@custom).to_json.html_safe
		end

		private

			def method_missing(method, value, &block)
				@custom[method.to_s.chomp("=")] = value
			end
	end
end
