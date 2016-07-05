module MagicBeans
	class Config
		class Crypt

			attr_accessor :offset

			def initialize
				@offset ||= 64
			end
		end
	end
end