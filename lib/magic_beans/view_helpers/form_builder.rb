require 'digest/sha1'
module MagicBeans
	module ViewHelpers
		module FormBuilder

			def upload_field(method, options = {})
				field = UploadField.new(@object, method, options)
				file_field field.method, field.options
			end

			class UploadField

				include ActionDispatch::Routing::UrlFor
				include ActionDispatch::Routing::PolymorphicRoutes
				include Rails.application.routes.url_helpers

				def initialize(model, method, options)
					@model = model
					@method = method
					@options = options
					prepare
				end

				def method
					@method.to_sym
				end

				def options
					@options ||= {}
				end

				def prepare
					files = [@model.send(method)].flatten.compact.map do |upload|
						if !upload.nil? && !upload.file.nil? && File.exist?(upload.file.path)
							{ Digest::SHA1.hexdigest(upload.file.try(:filename)) => { url: upload.url, status: :added, accepted: true, name: upload.file.try(:filename), size: upload.file.try(:size), type: upload.file.try(:content_type) } }
						end
					end.compact.reduce(:merge)
					options[:data] ||= {}
					options[:data][:upload] ||= polymorphic_path(@model.class, action: :upload)
					options[:data][:files] = files.to_json
				end
			end
		end
	end
end