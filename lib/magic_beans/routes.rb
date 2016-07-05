module MagicBeans
	module Routes

		def uploadable(resource)
			post "upload", to: "#{controller_path(resource)}#upload", as: "upload_#{resource.to_s.underscore}"
		end

		def croppable(resource)
			get "/:id/image", to: "#{controller_path(resource)}#image"
			patch "/:id/crop", to: "#{controller_path(resource)}#crop", as: "crop_#{resource.to_s.underscore.singularize}"
			put "/:id/crop", to: "#{controller_path(resource)}#crop"
		end

		private

			def controller_path(resource)
				"#{resource.to_s.underscore}".strip
			end
	end
end
