require "magic_beans/version"
require "magic_beans/config"
require "magic_beans/assets"

module MagicBeans
	def self.setup
		yield config
	end

	def self.config
		@config ||= MagicBeans::Config.new
	end

	def self.assets
		@assets ||= MagicBeans::Assets.new
	end

	def self.svgable?(file)
		[config.svg_build_environment].flatten.include?(Rails.env) && !assets.find(file).nil?
	end

	def self.log(tag, message)
		@logger ||= ActiveSupport::TaggedLogging.new(config.logger)
		puts "[Magic Beans] [#{tag}] #{message}".light_blue
		@logger.tagged("Magic Beans") { @logger.tagged(tag) { @logger.info message } }
	end

	class Error < StandardError; end
end

require "magic_beans/engine"
