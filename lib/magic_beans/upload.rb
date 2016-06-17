<<<<<<< HEAD
=======
require 'digest/sha1'
>>>>>>> 8ca71828528c4a5e4136f50847aa057d67ef3282
module MagicBeans
	module Upload

		def self.included(base)
			base.send :extend, ClassMethods
<<<<<<< HEAD
			base.send :after_action, :commit_uploads
			base.send :after_action, :remove_uploads
=======
			base.send :before_action, :init_upload_resource
			base.send :before_action, :remove_uploads, only: [:create, :update]
>>>>>>> 8ca71828528c4a5e4136f50847aa057d67ef3282
		end

		module ClassMethods

			def upload_mounts
				@mounts ||= []
			end

			def upload_mount_names
				upload_mounts.map(&:name)
			end

			def upload_for(mount, options={})
				upload_mounts << Mount.new(mount, options)
			end
		end

		class Mount

			attr_accessor :options

			def initialize(name, options={})
				@name = name
				@options = options.deep_symbolize_keys
				@options[:only] ||= [:create, :update]
				@options[:except] ||= []
				@options[:except] = [@options[:except]] unless @options[:except].is_a?(Array)
				@options[:except] << :upload
			end

			def name
				@name.to_s
			end

			def resource(klass)
				if options[:resource].respond_to? :call
					options[:resource].call(klass)
				else
					klass.send :instance_variable_get, "@#{klass.controller_name.to_s.classify.downcase}"
				end
			end

			def only?(action)
				return false if options[:only].blank?
				[options[:only]].flatten.map(&:to_s).include? action.to_s
			end

			def except?(action)
				[options[:except]].flatten.map(&:to_s).include? action.to_s
			end

			def allowed?(action)
				only?(action) && !except?(action)
			end

			def multiple?
				options.has_key?(:multiple) && options[:multiple] == true
			end
		end

		def upload

			result = upload_params.map do |key, file|
				begin
					# Temporarily create the model for validation purposes, it will not be saved
					model = resource.new(key.to_sym => file)

					# Manually check validity to pre-check whether or not upload is valid
					model.valid?

					# If upload was not valid check that here
					if model.errors.messages.keys.any? { |k| uploaders.keys.map(&:to_s).include?(k.to_s) }
						{ errors: model.errors.messages.map { |k, message| message if uploaders.keys.map(&:to_s).include?(k.to_s) }.flatten.compact }
					else
						{ uploads: [file].flatten.map { |f| MagicBeans::UploadTemp.create(file: f, multiple: file.is_a?(Array), mount: key, resource: resource_name, name: f.original_filename).hash } }
					end
				rescue => e
					# Output any errors from attempting to upload
					{ errors: [e.message] }
				end
			end.reduce({ uploads: [], errors: [] }, :merge)

			MagicBeans.log("Upload", result[:errors], true) if result[:errors].any?

			render json: result, status: (result[:errors].any? ? 500 : 200)
		end

		private

			def remove_uploads
				processor = MagicBeans::UploadProcessor.new(self, action_name)
				processor.remove! removes

				#results = removes.map do |name, action|
				#	mount = mount_for(name)
				#	action[:remove].map { |id| remove_upload(mount, id) } unless mount.nil?
				#end
			end

			def commit_uploads
				processor = MagicBeans::UploadProcessor.new(self, action_name)
				processor.process! commits
			end

			def upload_params
				permittable = uploaders.map { |name, uploader| (resource.new.respond_to?("#{name}_urls") ? { name => [] } : name) }
				params.require(resource_name.to_sym).permit(permittable)
			end

			def commit_params
				permittable = self.class.upload_mounts.map do |mount|
					{ mount.name => { commit: [] } } if mount.allowed?(action_name)
				end.compact

				return {} if permittable.blank?
				params.require(resource_name.to_sym).permit(permittable)
			end

			def remove_params
				permittable = self.class.upload_mounts.map do |mount|
					{ mount.name => { remove: [] } } if mount.allowed?(action_name)
				end.compact

				return {} if permittable.blank?
				params.require(resource_name.to_sym).permit(permittable)
			end

			def commits
				[params[:upload_commit]].flatten.compact
			end

			def removes
				remove_params.map { |mount_name, data| { mount_name => data[:remove] } }.reduce(Hash.new, :merge)
			end

			def remove_upload(mount, id)
				begin
					if mount.multiple?
						remaining = @resource.send(mount.name)
						remaining.reject! do |upload|
							if Digest::SHA256.hexdigest "#{resource_name}_#{upload.file.try(:filename)}" == id
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

			def resource
				@resource ||= controller_name.to_s.classify.safe_constantize
			end

			def resource_name
				resource.name.underscore
			end

			def uploaders
				resource.uploaders || {}
			end

			def mount_for(name)
				self.class.upload_mounts.find { |mount| mount.name == name.to_s }
			end
	end
end
