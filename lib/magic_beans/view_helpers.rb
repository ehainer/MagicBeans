module MagicBeans
	module ViewHelpers

		def svg_tag(source, image = nil, **options)
			svg = MagicBeans::SVG.new(source, image, options.merge(asset_lookup: true))
			svg.html_tag
		end
	end
end
