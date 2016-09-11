require 'tempfile'
module MagicBeans
	module Crop

		def croppable(resource = nil, **args)
			extend ClassMethods
			include InstanceMethods

			resource_class = resource.to_s.constantize rescue nil

			raise MagicBeans::Crop::ArgumentError.new("Unknown resource class '#{resource}' defined") if resource_class.blank?

			@cropper = Cropper.new(resource_class, **args)
		end

		module ClassMethods

			attr_accessor :cropper

		end

		module InstanceMethods
			def crop
				begin
					type = crop_params[:type].to_s.underscore.to_sym

					if crop_image?
						cropper.resource.update(crop_image)
					end

					from = cropper.resource.try(type).try(:path)

					raise MagicBeans::Crop::InvalidMount.new("Unknown image path for uploader mount with name '#{type}'") if from.blank?

					# Create a temp file to store the newly cropped image
					to = Tempfile.new(["#{cropper.resource.id}_#{type}", File.extname(from)])

					# Crop the image, scale up if it's smaller than the required crop size
					img = ::MiniMagick::Image.new(from)
					img.combine_options do |c|
						c.crop("#{crop_params[:width]}x#{crop_params[:height]}+#{crop_params[:x]}+#{crop_params[:y]}")
						c.resize "300x300" if img.width < 300 || img.height < 300
						c.repage.+
					end
					img.write to.path
					to.close

					# Set the new image on the resource
					cropper.resource.send("#{type}=", to)

					# Remove the temp file
					to.unlink

					# Output the results, or redirect, depending on what was requested
					respond_to do |format|
						resource = cropper.resource
						if resource.save
							# Recreate the versions defined in the uploader to ensure the images are generated
							resource.send(type).recreate_versions!

							# If a success method/proc was defined, do that, otherwise redirect to the resource
							format.html do
								if cropper.has_success?
									cropper.success
									return
								else
									redirect_to(resource)
								end
							end
							format.json { render json: cropper.versions(type) }
						else
							raise MagicBeans::Crop::RecordInvalid.new(resource: resource)
						end
					end
				rescue MagicBeans::Crop::RecordInvalid => e
					respond_to do |format|
						# If a failure method/proc was defined, do that, otherwise redirect to the resource with the flash
						format.html do
							if cropper.has_failure?
								cropper.failure
								return
							else
								redirect_to(cropper.resource, alert: e.data[:resource].errors.full_messages)
							end
						end
						format.json { render json: cropper.versions(type).merge(error: e.message), status: 400 }
					end
				end
			end

			def image
				type = params[:type].to_s.underscore.to_sym
				render json: { url: cropper.resource.try(type).try(:url) + "?#{Time.now.to_i}" }
			end

			def cropper
				self.class.cropper.controller = self
				self.class.cropper
			end

			private

				def crop_image?
					crop_params[:image] && crop_params[:type]
				end

				def crop_image
					if MagicBeans::UploadTemp.exists?(crop_params[:image])
						upload = MagicBeans::UploadTemp.find(crop_params[:image])
						{ crop_params[:type] => File.open(upload.upload.path) }
					else
						{}
					end
				end
	
				def crop_params
					data = params.require(:crop).permit(:x, :y, :width, :height, :ajax, :id, :type, :image)
	
					# Sanitize values that can only be numeric values, since they get passed directly to a MiniMagick command
					[:x, :y, :width, :height].each do |arg|
						raise MagicBeans::Crop::ArgumentError.new("Value passed for crop '#{arg}' is not numeric") unless (true if Float(data[arg]) rescue false)
					end

					# If all was well, return the param data
					data
				end
		end

		class Cropper

			attr_accessor :options, :controller, :resource_class

			def initialize(resource, **args)
				@resource_class = resource
				@options = args.compact.deep_symbolize_keys.select { |key, _| [:resource, :success, :failure].include?(key) }
			end

			def versions(type)
				resource.send(type).versions.map do |version, uploader|
					{ version => uploader.url + "?#{Time.now.to_i}" }
				end.reduce(:merge).merge(type.to_sym => resource.send(type).url + "?#{Time.now.to_i}")
			end

			def success
				if options[:success].respond_to? :call
					options[:success].call resource
					true
				elsif !options[:success].blank? && controller.respond_to?(options[:success])
					controller.send options[:success], resource
					true
				else
					false
				end
			end

			def failure
				if options[:failure].respond_to? :call
					options[:failure].call resource
					true
				elsif !options[:failure].blank? && controller.respond_to?(options[:failure])
					controller.send options[:failure], resource
					true
				else
					false
				end
			end

			def has_success?
				if options[:success].respond_to?(:call) || (!options[:success].blank? && controller.respond_to?(options[:success]))
					true
				else
					false
				end
			end

			def has_failure?
				if options[:failure].respond_to?(:call) || (!options[:failure].blank? && controller.respond_to?(options[:failure]))
					true
				else
					false
				end
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
				elsif !params[:id].blank?
					resource_class.to_s.classify.safe_constantize.find(params[:id])
				else
					resource_class.to_s.classify.safe_constantize.new
				end
			end
		end
	end
end
