module MagicBeans
	module SassHelpers
		def svg_icon(source, image = nil, size = nil, color = nil)
			svg = MagicBeans::SVG.new(source.to_s, image.to_s, { size: size.to_s, color: color.to_s })

			if svg.exists?
				Sass::Script::Value::String.new "url(\"#{svg.image_asset_path}\");\nbackground-image: url(\"#{svg.svg_asset_path}\"), linear-gradient(transparent, transparent)"
			else
				Sass::Script::Value::String.new "none"
			end
		end

		Sass::Script::Functions.declare :svg_icon, [], var_args: true, var_kwargs: true
	end
end
