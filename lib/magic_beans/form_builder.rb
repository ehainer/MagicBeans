module MagicBeans
	module FormBuilder

		def upload_field(method, **options)
			field = UploadField.new(@object, method, options)
			file_field field.method, field.options
		end

		class UploadField

			include ::ActionDispatch::Routing::PolymorphicRoutes
			include ::Rails.application.routes.url_helpers
			include ::MagicBeans::Engine.routes.url_helpers

			def initialize(model, method, options)
				@model = model
				@method = method.to_sym
				@options = options.deep_symbolize_keys
				prepare
			end

			def method
				@method.to_sym
			end

			def options
				@options ||= {}
			end

			def prepare
				options[:data] ||= {}
				options[:data][:upload] ||= polymorphic_path(@model.class, action: :upload)

				if options[:data][:preserve] == true
					options[:data][:files] = [@model.send(method)].flatten.compact.map do |upload|
						if !upload.nil? && !upload.file.nil? && File.exist?(upload.file.path)
							{ Digest::SHA256.hexdigest("#{@model.class.name.underscore}_#{@model.id}_#{method}_#{upload.file.try(:filename)}") => { url: upload.url, status: :added, accepted: true, name: upload.file.try(:filename), size: upload.file.try(:size), type: upload.file.try(:content_type) } }
						end
					end.compact.reduce(:merge).to_json
				end
			end
		end
	end
end