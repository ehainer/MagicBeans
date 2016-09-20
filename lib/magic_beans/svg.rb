module MagicBeans
	class SVG

		include ActionView::Helpers

		attr_reader :svg_name, :image_name, :options

		def initialize(svg_name, image_name = nil, **opts)
			@svg_name = svg_name.is_a?(Symbol) ? svg_name.to_s.dasherize : svg_name.to_s.strip
			@image_name = (image_name.blank? ? svg_name : image_name)
			@options = opts

			prepare_options

			if !exists? && MagicBeans.config.svg.is_buildable? && can_create?
				create
			elsif exists?
				MagicBeans.log("SVG", "No SVG needs processing. #{image_path} already exists.")
			elsif !MagicBeans.config.svg.is_buildable?
				MagicBeans.log("SVG", "Not processing #{svg_path}, MagicBeans SVG processor is not configured to run in the environment '#{Rails.env}'")
			end
		end

		def html_tag
			image_tag svg_asset_path, attributes
		end

		def attributes
			attrs = { data: {} }
			attrs[:size] = size unless size.blank?
			attrs[:data] = { svg: true, image: image_asset_path, size: size }.reject { |k,v| v.blank? }
			attrs[:class] = options[:class] if options.has_key?(:class)
			attrs
		end

		def exists?
			File.exists?(image_path) && File.exists?(svg_output_path)
		end


		# Image Name / Path
		def image
			name = image_name.is_a?(Symbol) ? image_name.to_s.dasherize : image_name.to_s.strip
			name.gsub! /(^("|'))|(('|")$)/, ""
			name.gsub! /\.svg$/i, ""
			name << ".#{image_extension}" unless /\.[a-z]+$/i =~ name
			name.gsub! Regexp.new("#{image_extension}$", Regexp::IGNORECASE), [color, size, image_extension].reject(&:blank?).join(".")
			name
		end

		def image_path
			File.join MagicBeans.config.svg.fallback_directory, image
		end

		def image_asset_path
			if options[:asset_lookup]
				ActionController::Base.helpers.asset_path(image)
			else
				begin
					Rails.application.assets.find_asset(image).try(:digest_path) || false
				rescue => e
					false
				end
			end
		end


		# SVG Name / Path
		def svg
			source.gsub /svg$/i, [color, "svg"].reject(&:blank?).join(".")
		end

		def svg_path
			File.join MagicBeans.config.svg.icon_directory, svg
		end

		def svg_output_path
			File.join MagicBeans.config.svg.fallback_directory, svg
		end

		def svg_asset_path
			if options[:asset_lookup]
				ActionController::Base.helpers.asset_path(svg)
			else
				begin
					Rails.application.assets.find_asset(svg).try(:digest_path) || false
				rescue => e
					false
				end
			end
		end


		# SVG Source Name / Path
		def source
			name = svg_name.dup
			name.gsub! /(^("|'))|(('|")$)/, ""
			name << ".svg" unless /\.svg$/i =~ name
			name
		end

		def source_path
			File.join MagicBeans.config.svg.icon_directory, source
		end


		def create
			begin
				prepare
				::MiniMagick::Tool::Convert.new do |convert|
					convert.merge! ["-background", "none"]
					convert.merge! ["-gravity", "center"]
					if size
						convert.merge! ["-density", 1200]
						convert.merge! ["-resize", size] unless size.blank?
						convert.merge! ["-extent", size] unless size.blank?
					end
					convert << svg_output_path
					convert << image_path
					convert
				end
				MagicBeans.log("SVG", "Created #{image_path} from #{svg_output_path}")
				true
			rescue => e
				MagicBeans.log("SVG", e.message, true)
				false
			end
		end


		def prepare
			if !color.blank? && !File.exists?(svg_output_path)
				# Get the svg source directory path
				filedir = File.dirname(source_path)

				# Get the svg contents
				content = File.read(source_path)

				# Set the color of any path/stroke in the svg
				content.gsub! /fill=\"[^\"]+\"/, "fill=\"#{options[:color]}\""
				content.gsub! /stroke=\"[^\"]+\"/, "stroke=\"#{options[:color]}\""

				# Write the new svg file
				File.open(svg_output_path, "w") { |f| f.puts content }

				MagicBeans.log("SVG", "Created #{svg_output_path} from #{source_path}")
			end
		end


		def image_extension
			extensions.first
		end

		def extensions
			options[:extension]
		end

		def color
			options[:color].to_s.gsub(/[^A-Z0-9]+/i, "").upcase
		end

		def size
			return options[:size].to_s.gsub(/(^("|'))|(('|")$)/, "") if /\d+x\d+/ =~ options[:size].to_s
			return "#{options[:size]}x#{options[:size]}".to_s.gsub(/(^("|'))|(('|")$)/, "") if /\d+/ =~ options[:size].to_s
			options[:size].to_s.gsub /(^("|'))|(('|")$)/, ""
		end

		def can_create?
			MagicBeans.log("SVG", "Unknown SVG: #{source_path}", true) unless File.exists?(source_path)
			File.exists?(source_path)
		end

		private

			def prepare_options
				options.deep_symbolize_keys!
				options[:asset_lookup] ||= false
				options[:extension] = nil unless options[:extension].is_a?(Array)
				options[:extension] ||= [:png, :jpg, :gif]
				options[:extension].flatten!
				options[:extension].map!(&:to_s)
				options[:size] ||= nil
			end
	end
end
