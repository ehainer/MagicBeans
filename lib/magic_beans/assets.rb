module Cloud
	class Assets

		def initialize
		end

		def find(file)
			files(file)[file]
		end

		def files(type = "*")
			assets = Hash.new
			Rails.application.config.assets.paths.each do |path|
				Dir.glob("#{path}/**/#{type}").each { |file| assets[File.basename(file)] = file }
			end
			assets
		end
	end
end
