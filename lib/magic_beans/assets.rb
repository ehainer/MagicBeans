module MagicBeans
	class Assets

		def find(file)
			files(file)[file]
		end

		def files(type = "*", sub_dir = "**")
			assets = Hash.new
			Rails.application.config.assets.paths.each do |path|
				Dir.glob("#{path}/#{sub_dir}/#{type}").each { |file| assets[File.basename(file)] = file }
			end
			assets
		end
	end
end
