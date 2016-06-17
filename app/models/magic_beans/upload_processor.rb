module MagicBeans
	class UploadProcessor

		attr_accessor :commits, :controller, :mounts, :action

		def initialize(controller, action)
			@commits = []
			@controller = controller
			@mounts = controller.class.upload_mounts
			@action = action

			# Create the commit directory, temporarily store the attachments into it
			# This directory and all of it's contents are destroyed immediately upon completion
			FileUtils.mkdir_p commit_directory
		end

		def process!(commits)
			# Set the commits, ensure they are an array with no nils
			@commits = [commits].flatten.compact

			organized_uploads.each do |mount_name, files|
				# Find the associated upload mount object, defined through the use of `upload_for` in a controller
				mount = mounts.find { |mount| mount.name == mount_name.to_s }

				# Raise if the mount could not be found
				raise MagicBeans::Error.new "Mount with name #{mount_name} not found within #{controller.class.name}" if mount.nil?

				# Exit if the current controller action (create, update, etc...) is not
				# permitted as one of the actions where uploads can be committed
				return unless mount.allowed? action

				# Update the resource with the files
				mount.resource(controller).send :update, { mount_name => files }
			end

			# Destroy all temp upload objects and their associated files, and the commit directory
			destroy
		end

		def remove!(removals)
			removals.each do |mount_name, hashes|
				# Find the associated upload mount object, defined through the use of `upload_for` in a controller
				mount = mounts.find { |mount| mount.name == mount_name.to_s }

				# Ensure hashes to remove is an array clear of any nils
				hashes = [hashes].flatten.compact

				# Raise if the mount could not be found
				raise MagicBeans::Error.new "Mount with name #{mount_name} not found within #{controller.class.name}" if mount.nil?

				# Exit if the current controller action (create, update, etc...) is not
				# permitted as one of the actions where uploads can be removed
				return unless mount.allowed? action

				uploads = mount.resource(controller).send mount_name

				# Get the resource name, used in the hashed filename to identify the upload
				resource_name = mount.resource(controller).class.name.underscore

				puts hashes.to_yaml

				if uploads.is_a?(Array)
					uploads.reject! { |upload| puts "#{resource_name}_#{upload.file.filename}"; puts Digest::SHA256.hexdigest("#{resource_name}_#{upload.file.filename}"); hashes.include? Digest::SHA256.hexdigest("#{resource_name}_#{upload.file.filename}") }

					# TODO: Bizarre issue where last file to be removed is removed physically, but not from the DB
					# Temporary workaround is to update the column to be nil if no more images remaining
					# update_attribute works fine as long as there are more than 0 files remaining
					#if uploads.empty?
					#	@resource.update_column(mount_name, nil)
					#else
					#	@resource.update_attribute(mount_name, remaining)
					#end

					mount.resource(controller).send :update, { mount_name => uploads }
				else
					mount.resource(controller).send :update, { mount_name => uploads } if hashes.include? Digest::SHA256.hexdigest("#{resource_name}_#{uploads.file.filename}")
				end
			end
		end

		private

			def uploads
				@uploads ||= MagicBeans::UploadTemp.where(key: @commits)
			end

			def organized_uploads
				organized = Hash.new

				uploads.each do |temp|
					commit_path = File.join(commit_directory, temp.name)

					# Create a copy of the upload file as a tempfile with
					# the same extension as the file we're going to save
					FileUtils.cp temp.file_path, commit_path

					if temp.multiple?
						organized[temp.mount] ||= []
						organized[temp.mount] << File.open(commit_path)
					else
						organized[temp.mount] = File.open(commit_path)
					end
				end

				organized
			end

			def destroy
				uploads.destroy_all
				FileUtils.rm_rf commit_directory
			end

			def commit_directory
				File.join MagicBeans.config.upload.temp_directory, "commit", process_id
			end

			def process_id
				@process_id ||= SecureRandom.uuid
			end
	end
end