module MagicBeans
	module ViewHelpers

		extend ActiveSupport::Autoload

		autoload :SVG

		autoload :FormBuilder

		def svg_tag(source, image = nil, **options)
			svg = SVG.new(source, image, options)
			svg.html_tag
		end
	end
end
