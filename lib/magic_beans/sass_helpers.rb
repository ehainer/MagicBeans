module MagicBeans
	module SassHelpers
		def svg_icon(source, image = nil, size = nil)
			svg = ViewHelpers::SVG.new(source, image, { size: size })
			svg.log
			if svg.fallback
				Sass::Script::String.new "url(#{svg.fallback});\nbackground-image: url(\"#{svg.path}\"), linear-gradient(transparent, transparent)"
			else
				Sass::Script::String.new "none;"
			end
		end

		Sass::Script::Functions.declare :svg_icon, [], var_args: true, var_kwargs: true
	end
end
