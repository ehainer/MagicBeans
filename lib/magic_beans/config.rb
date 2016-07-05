require "sprockets"
require "magic_beans/config/js"
require "magic_beans/config/upload"
require "magic_beans/config/svg"
require "magic_beans/config/locale"
require "magic_beans/config/twilio"
require "magic_beans/config/secrets"
require "magic_beans/config/crypt"

module MagicBeans
	class Config

		attr_accessor :logger, :packages, :debug, :js, :upload, :svg, :locale, :twilio, :secrets, :crypt

		attr_accessor :base_url

		def initialize
			@logger = Logger.new(Rails.root.join("log", "magic_beans.log"))
			@debug ||= false
			@packages ||= []

			@js = Js.new
			@upload = Upload.new
			@svg = Svg.new
			@locale = Locale.new
			@twilio = Twilio.new
			@secrets = Secrets.new
			@crypt = Crypt.new
		end

		def to_json
			{ stylesheet: ActionController::Base.helpers.asset_path("tinymce.css") }
				.merge(js.to_h) # allows overriding the stylesheet param if set
				.merge(packages: @packages, debug: @debug) # ensure these two params are always set here
				.to_json.html_safe
		end
	end
end
