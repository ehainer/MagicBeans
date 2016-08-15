module MagicBeans
	class Config
		class Secrets

			def initialize
				@yaml = HashWithIndifferentAccess.new(YAML.load(File.read(Rails.root.join("config", "secrets.yml"))))
				@yaml = @yaml[Rails.env.to_sym]
			end

			private

				def method_missing(method, *arguments, &block)
					@yaml[method.to_sym]
				end
		end
	end
end