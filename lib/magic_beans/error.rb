module MagicBeans

	class Error < StandardError

		attr_accessor :data

		def initialize(*args, **data)
			super(*args)
			@data = data.deep_symbolize_keys
			log
		end

		def log
			msg = self.message
			data.each { |key, value| msg = msg + "\n\t#{key}: #{value.inspect}" }
			msg = msg + "\n" if data.length > 0
			
			MagicBeans.log(self.class.name.split("::", 2).last, msg, true)
		end
	end

	module Crop

		class InvalidMount < MagicBeans::Error
		end

		class RecordInvalid < MagicBeans::Error
		end

		class ArgumentError < MagicBeans::Error
		end

	end

end