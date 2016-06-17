require 'tempfile'
module MagicBeans
	module Crop

		def self.included(base)
			base.send :extend, ClassMethods
		end

		module ClassMethods

			def crops
				@crops ||= []
			end

			def crop_for(name, options={})
				crops << Crop.new(name, options)
			end
		end

		class Crop

			def initialize(name, options)
				@name = name
				@options = options.deep_symbolize_keys
			end

			def name
				@name.to_s
			end

			def resource(klass)
				if @options[:resource].respond_to? :call
					@options[:resource].call(klass)
				else
					klass.send :instance_variable_get, "@#{klass.controller_name.to_s.classify.downcase}"
				end
			end

			def versions(klass, type)
				resource(klass).send(type).versions.map { |version, uploader| { version => uploader.url } }.reduce(:merge).merge(type.to_sym => resource(klass).send(type).url)
			end

			def success(klass, res)
				klass.send(@options[:success], res) if !@options[:success].blank? && klass.respond_to?(@options[:success])
			end

			def failure(klass, res)
				klass.send(@options[:failure], res) if !@options[:failure].blank? && klass.respond_to?(@options[:failure])
			end
		end

		def crop
			crop_type = crop_params[:type]
			cropper = crop_for(crop_type)

			if cropper
				resource = cropper.resource(self)
				from = resource.try(crop_type).path

				# Create a temp file to store the newly cropped image
				to = Tempfile.new(["#{resource.id}_#{crop_type}", File.extname(from)])

				# Crop the image, scale up if it's smaller than the required crop size
				img = MiniMagick::Image.new(from)
				img.crop("#{crop_params[:width]}x#{crop_params[:height]}+#{crop_params[:x]}+#{crop_params[:y]}")
				img.resize "300x300" if img.width < 300 || img.height < 300
				img.write to.path
				to.close

				# Set the new image on the resource
				resource.send("#{crop_type}=", to)

				# Remove the temp file
				to.unlink

				# Output the results, or redirect, depending on what was requested
				respond_to do |format|
					if resource.save
						# If a success method/proc was defined, do that, otherwise redirect to the resource
						format.html { cropper.success(self, resource) || redirect_to(resource) }
						format.json { render json: cropper.versions(self, crop_type) }
					else
						# If a failure method/proc was defined, do that, otherwise redirect to the resource with the flash
						format.html { cropper.failure(self, resource) || redirect_to(resource, alert: resource.errors.full_messages) }
						format.json { render json: cropper.versions(self, crop_type).merge(error: resource.errors.full_messages), status: 400 }
					end
				end
			else
				raise MagicBeans::Error.new("Unknown crop for uploader '#{crop_type}'")
			end

		end

		def image
			begin
				type = params[:type].to_s.underscore.to_sym
				cropper = crop_for(type)
				render json: { url: cropper.resource(self).try(type).url }
			rescue => e
				puts e.message
				render json: { url: "" }
			end
		end

		private

			def crop_params
				data = params.require(:crop).permit(:x, :y, :width, :height, :ajax, :id, :type)

				# Sanitize values that can only be numeric values, since they get passed directly to a MiniMagick command
				[:x, :y, :width, :height].each do |arg|
					raise MagicBeans::Error.new("Value passed for crop '#{arg}' is not numeric") unless (true if Float(data[arg]) rescue false)
				end

				# If all was well, return the param data
				data
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

			def crop_for(name)
				self.class.crops.find { |cropper| cropper.name == name.to_s }
			end
	end
end
