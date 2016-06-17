require "sass"
module MagicBeans
	module SassHelpers
		class Functions < ::Sass::Script::Functions
			#def svg_path(source, image = nil, **options)
			#	svg = ::MagicBeans::ViewHelpers::SVG.new(source, image, options)
			#	::Sass::Script::String.new "url(#{svg.fallback});\nbackground: url(\"#{svg.path}\"), linear-gradient(transparent, transparent)"
			#end
#
			#declare :svg_path, args: [:source], :var_kwargs => true
		end
	end
end