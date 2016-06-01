require "magic_beans/version"
require "magic_beans/config"
require "magic_beans/assets"
require "magic_beans/upload"
require "magic_beans/crop"

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
		[config.svg_build_environment].flatten.map(&:to_s).include?(Rails.env.to_s) && !assets.find(file).nil?
	end

	def has_package?(package)
		config.packages.map(&:to_s).include?(package.to_s)
	end

	def self.log(tag, message, error = false)
		@logger ||= ActiveSupport::TaggedLogging.new(config.logger)
		if config.debug
			if error
				puts "[Magic Beans] [#{tag}] #{message}".red
			else
				puts "[Magic Beans] [#{tag}] #{message}".light_blue
			end
		end
		@logger.tagged("Magic Beans") { @logger.tagged(tag) { @logger.info message } }
	end

	class Error < StandardError; end
end

require "magic_beans/engine"
