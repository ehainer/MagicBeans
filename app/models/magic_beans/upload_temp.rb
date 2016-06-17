module MagicBeans
	class UploadTemp < ActiveRecord::Base

		attr_accessor :file

		before_create :save_file

		before_destroy :remove_file

		before_save :set_key

		DISTRIBUTE_LEVEL = 2

		def file_path
			File.join MagicBeans.config.upload.temp_directory, resource, distributed_path, hash
		end

		def save_file
			# Create storage directory
			FileUtils.mkdir_p File.join(MagicBeans.config.upload.temp_directory, resource, distributed_path)
			
			# Save the file with name [hash]
			File.open file_path, "wb" do |f|
				f.write self.file.tempfile.read
			end
		end

		def hash
			Digest::SHA256.hexdigest "#{resource}_#{name}"
		end

		private

			def set_key
				self.key = hash
			end

			def remove_file
				FileUtils.rm file_path rescue nil
			end

			def distributed_path
				File.join(hash[0..(DISTRIBUTE_LEVEL-1)].split(""))
			end
	end
end
