module MagicBeans
	class Config
		class Js

			attr_accessor :custom

			def initialize
				@custom = Hash.new
			end

			def to_h
				@custom
			end

			private

				def method_missing(method, value, &block)
					@custom[method.to_s.chomp("=")] = value
				end
		end
	end
end