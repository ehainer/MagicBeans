module MagicBeans
	class UploadController < ApplicationController

		def create
			upload = MagicBeans::UploadTemp.new(upload_data)
			if upload.save
				render json: { success: true }
			else
				render json: { success: false, errors: upload.errors.full_messages }
			end
		end

		private

			def upload_data
				upload_params.map do |type, file|
					if file.is_a? Array
						{ uploads: file, upload_type: type }
					else
						{ upload: file, upload_type: type }
					end
				end.reduce(Hash.new, :merge).merge(uploaders: uploaders)
			end

			def upload_params
				permittable = uploaders.keys.map do |name|
					if model.respond_to? "#{name}_urls"
						{ name => [] }
					else
						name
					end
				end
				params.require(params[:resource].to_sym).permit(permittable)
			end

			def uploader(type)
				uploaders[type.to_sym]
			end

			def uploaders
				model.uploaders || {}
			end

			def model
				@model ||= params[:resource].to_s.classify.safe_constantize
			end
	end
end