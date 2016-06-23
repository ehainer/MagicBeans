require "magic_beans/engine"
require "magic_beans/config"
require "magic_beans/assets"
require "magic_beans/upload"
require "magic_beans/crop"
require "magic_beans/locale"
require "magic_beans/notifyable"

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
		[config.svg.build_environment].flatten.map(&:to_s).include?(Rails.env.to_s) && !assets.find(file).nil?
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

	def self.digits
		rnd = Random.new(Rails.application.config.secret_key_base.to_i(36))
		"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".split("").shuffle(random: rnd)
	end

	def self.encode(val)
		radix = digits.length
		i = val.to_i

		raise ArgumentError.new("Value #{val} cannot be less than zero") if i < 0

		out = []
		begin
			rem = i % radix
			i /= radix
			out << digits[rem]
		end until i == 0

		out.reverse.join
	end

	def self.decode(val)
		input = val.to_s.split("")
		out = 0

		begin
			chr = input.shift
			out += (digits.length**input.length)*digits.index(chr)
		end until input.empty?

		out
	end

	class Error < StandardError; end
end
