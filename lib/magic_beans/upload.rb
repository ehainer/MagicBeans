require 'digest/sha1'
module MagicBeans
	module Upload

		def self.included(base)
			base.send :extend, ClassMethods
			base.send :before_action, :init_upload_resource
			base.send :before_action, :remove_uploads, only: [:create, :update]
		end

		module ClassMethods

			def upload_mounts
				@mounts ||= []
			end

			def upload_mount_names
				upload_mounts.map { |mount| mount.name }
			end

			def upload_for(mount, options={})
				upload_mounts << Mount.new(mount, options)
			end
		end

		class Mount

			def initialize(name, options={})
				@name = name
				@options = options.deep_symbolize_keys
			end

			def name
				@name.to_s
			end

			def options
				@options || {}
			end

			def urls_for(resource)
				urls = [resource.send(name)].flatten.compact.map do |upload|
					if upload.file
						response = { id: Digest::SHA1.hexdigest(upload.file.filename), url: upload.url, name: upload.file.filename }
						if has_versions?
							versions.each do |version|
								response[version.to_sym] = upload.try(version).url
							end
						end
						response
					end
				end.compact

				return urls if multiple?
				urls.first
			end

			def multiple?
				options.has_key?(:multiple) && options[:multiple] == true
			end

			def has_versions?
				!versions.empty?
			end

			def versions
				[options[:versions]].flatten.compact
			end
		end

		def upload
			begin
				upload_params.each do |name, files|
					mount = mount_for(name)
					unless mount.nil?
						if mount.multiple?
							# If multiple uploads are allowed, merge any previously uploaded files with the new ones
							existing = @resource.send(mount.name)
							existing += files
							@resource.send("#{mount.name}=", existing.compact)
						else
							# Remove existing file if exists
							@resource.send("remove_#{mount.name}!") unless @resource.send("#{mount.name}").nil?
							# Single file, just set it on the model
							@resource.send("#{mount.name}=", files)
						end
					end
				end

				# Manually check validity to pre-check whether or not upload is valid
				@resource.valid?

				# If upload was not valid check that here
				raise if @resource.errors.messages.keys.any? { |key| self.class.upload_mount_names.include?(key.to_s) }

				# Save the record, but don't validate, we are only after checking the validity of the upload
				@resource.save!(validate: false)

				# Render the response json
				respond_to do |format|
					uploads = self.class.upload_mounts.map do |mount|
						{ mount.name => mount.urls_for(@resource) }
					end
					response = {
						id: @resource.id,
						resource: resource_name,
						method: :patch,
						uploads: uploads.reduce(:merge),
						html: {
							class: "edit_#{resource_name}",
							id: "edit_#{resource_name}_#{@resource.id}",
							action: polymorphic_path(@resource)
						}
					}
					format.json { render json: response }
				end
			rescue => e
				# Output any errors from attempting to upload
				full_messages = @resource.errors.messages.map { |k, message| message if self.class.upload_mount_names.include?(k.to_s) }.flatten.compact
				MagicBeans.log("Upload", full_messages, true)
				respond_to do |format|
					format.json { render json: full_messages, status: 500 }
				end
			end
		end

		private

			def init_upload_resource
				@resource = resource.find(resource_id) rescue resource.new
			end

			def remove_uploads
				results = remove_params.map do |name, action|
					mount = mount_for(name)
					action[:remove].map { |id| remove_upload(mount, id) } unless mount.nil?
				end
			end

			def upload_params
				permittable = self.class.upload_mounts.map do |mount|
					if mount.multiple?
						{ mount.name => [] }
					else
						mount.name
					end
				end
				params.require(resource_name.to_sym).permit(permittable)
			end

			def remove_params
				permittable = self.class.upload_mounts.map do |mount|
					{ mount.name => { remove: [] } }
				end
				params.require(resource_name.to_sym).permit(permittable)
			end

			def remove_upload(mount, id)
				begin
					if mount.multiple?
						remaining = @resource.send(mount.name)
						remaining.reject! do |upload|
							if Digest::SHA1.hexdigest(upload.file.try(:filename)) == id
								upload.try(:remove!)
								true
							else
								false
							end
						end

						# TODO: Bizarre issue where last file to be removed is removed physically, but not from the DB
						# Temporary workaround is to update the column to be nil if no more images remaining
						# update_attribute works fine as long as there are more than 0 files remaining
						if remaining.empty?
							@resource.update_column(mount.name, nil)
						else
							@resource.update_attribute(mount.name, remaining)
						end
					else
						@resource.send("remove_#{mount.name}!")
						@resource.save(validate: false)
					end
					true
				rescue => e
					false
				end
			end

			def resource_id
				params[:id]
			end

			def resource
				controller_name.to_s.classify.constantize
			end

			def resource_name
				resource.name.underscore
			end

			def mount_for(name)
				self.class.upload_mounts.find { |mount| mount.name == name.to_s }
			end
	end
end
