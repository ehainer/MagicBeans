module MagicBeans
	module Upload

		def uploadable(resource = nil, **args)
			extend ClassMethods
			include InstanceMethods

			resource_class = resource.to_s.constantize rescue nil

			raise ArgumentError.new("Unknown resource class '#{resource}' defined") if resource_class.blank?

			@uploader = Uploader.new(resource_class, **args)

			after_action { uploader.process }
		end

		module ClassMethods

			attr_accessor :uploader

		end

		module InstanceMethods

			def upload
				result = uploader.upload
				render json: result, status: (result.has_key?(:errors) ? 500 : 200)
			end

			def uploader
				self.class.uploader.controller = self
				self.class.uploader
			end
			
		end

		class Uploader

			attr_accessor :options, :controller, :resource_class

			def initialize(resource, **args)
				@resource_class = resource
				@options = args.compact.deep_symbolize_keys.select { |key, _| [:only, :except, :resource].include?(key) }
			end

			def upload
				if uploadable?
					# Temporarily create the model for validation purposes, it will not be saved
					model = resource_name.safe_constantize.new(upload_params)
	
					# Manually check validity to pre-check whether or not upload is valid
					model.valid?
	
					# If upload was not valid check that here
					if model.errors.messages.keys.any? { |key| uploaders.keys.map(&:to_s).include?(key.to_s) }
						{ errors: model.errors.messages.select { |key, _| uploaders.keys.map(&:to_s).include?(key.to_s) } }
					else
						{ uploads: { resource_param_name => uploads } }
					end
				else
					{ uploads: { resource_param_name => [] } }
				end
			end

			def process
				if removeable?
					remove_selected
				end

				if commitable?
					resource.update(commitable)
					cleanup_committed
				end
			end

			def remove_selected
				temp_ids = remove_params[:remove][:temp] || []
				file_ids = remove_params[:remove][:file] || []

				# If any temp ids, remove the temp upload objects and associated files
				if temp_ids.length > 0
					MagicBeans::UploadTemp.destroy(temp_ids) rescue nil
				end

				# If any file ids, remove iterate over resources current uploads and selectively remove matching
				if file_ids.length > 0
					# Exclude any uploader names which are already blank on our resource
					uploaders.keys.reject { |name| resource.send(name).blank? }.each do |name|
						uploads = resource_uploads[name].reject { |_| file_ids.include?(_.keys.first) }.flat_map { |_| _.values }

						MagicBeans.log "Upload", name
						MagicBeans.log "Upload", uploads

						if uploads.blank? # If uploads is blank, remove everything, only possible scenario for single file uploads if removed
							resource.send "remove_#{name}!"
						elsif resource.respond_to?("#{name}_urls") # If multiple uploads, update with the remaining uploads
							resource.update(name => uploads)
						end
					end
				end
			end

			def cleanup_committed
				MagicBeans::UploadTemp.destroy(commit_params[:commit]) rescue nil
			end

			def upload_params
				permittable = uploaders.map { |name, uploader| (resource.respond_to?("#{name}_urls") ? { name => [] } : name) }
				params.require(resource_param_name).permit(permittable)
			end

			def commit_params
				params.require(resource_param_name).permit(:commit => [])
			end

			def remove_params
				params.require(resource_param_name).permit(:remove => { file: [], temp: [] })
			end

			def uploaders
				resource.class.uploaders
			end

			def uploads
				upload_params.map do |name, files|
					[files].flatten.map do |file|
						MagicBeans::UploadTemp.create(upload: file, name: name, resource: resource_name).to_param
					end
				end.flatten
			end

			def params
				controller.send :params
			end

			def resource
				if options[:resource].respond_to? :call
					options[:resource].call controller
				elsif !options[:resource].blank? && controller.respond_to?(options[:resource])
					controller.send options[:resource]
				elsif controller.instance_variable_defined?("@#{resource_class.to_s.classify.demodulize.underscore}")
					controller.instance_variable_get "@#{resource_class.to_s.classify.demodulize.underscore}"
				else
					resource_class.to_s.classify.safe_constantize.new
				end
			end

			def resource_param_name
				resource_name.demodulize.underscore.to_sym
			end

			def resource_name
				resource.class.name.to_s
			end

			def only?(action)
				options[:only] ||= [:create, :update]
				options[:only] = [options[:only]].flatten
				options[:only].include?(action.to_sym)
			end

			def except?(action)
				options[:except] ||= []
				options[:except] = [options[:except]].flatten
				options[:except].include?(action.to_sym)
			end

			def commitable?
				only?(controller.action_name) && !except?(controller.action_name) && !params[resource_param_name].blank? && !commit_params[:commit].blank?
			end

			def removeable?
				only?(controller.action_name) && !except?(controller.action_name) && !params[resource_param_name].blank? && !remove_params[:remove].blank?
			end

			def uploadable?
				controller.action_name == "upload" && !params[resource_param_name].blank?
			end

			def resource_uploads
				uploaders.keys.flat_map do |name|
					uploads = [resource.send(name)].flatten.compact.map do |upload|
						{ Digest::SHA256.hexdigest("#{resource.class.name.underscore}_#{resource.id}_#{name}_#{upload.file.try(:filename)}") => upload }
					end
					{ name => uploads }
				end.reduce(Hash.new, :merge)
			end

			def commitable
				result = commit_params[:commit].map do |id|
					if MagicBeans::UploadTemp.exists?(id)
						upload = MagicBeans::UploadTemp.find(id)
						{ upload.name => upload.upload.path }
					end
				end

				result.compact.flat_map(&:entries).group_by(&:first).map do |k, v|
					if resource.respond_to?("#{k}_urls")
						Hash[k, v.map { |_| File.open(_.last) } + resource.send(k)]
					else
						Hash[k, File.open(v.flatten.last)]
					end
				end.reduce(Hash.new, :merge)
			end
		end
	end
end
