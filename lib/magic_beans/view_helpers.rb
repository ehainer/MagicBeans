module MagicBeans
	module ViewHelpers

		def svg_tag(source, image = nil, **options)
			svg = MagicBeans::SVG.new(source, image, { asset_lookup: true }.merge(options))
			svg.html_tag
		end
	end
end
