require "magic_beans/engine"
require "magic_beans/config"
require "magic_beans/assets"
require "magic_beans/upload"
require "magic_beans/crop"
require "magic_beans/locale"
require "magic_beans/crypt"
require "magic_beans/idable"
require "magic_beans/notifyable"
require "magic_beans/svg"
require "magic_beans/error"

require "colorize"

require "jquery-rails"
require "bourbon"
require "neat"

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

	def self.has_package?(package)
		config.packages.map(&:to_s).include?(package.to_s)
	end

	def self.log(tag, message, error = false)
		@logger ||= ActiveSupport::TaggedLogging.new(config.logger)
		if config.debug && !Rails.env.test?
			if error
				puts "[MagicBeans] [#{tag}] #{message}".light_red
			else
				puts "[MagicBeans] [#{tag}] #{message}".cyan
			end
		end
		@logger.tagged(Time.now.strftime("%Y-%m-%d %I:%M:%S %Z")) { @logger.tagged("MagicBeans") { @logger.tagged(tag) { @logger.send((error ? :error : :info), message) } } }
	end
end
