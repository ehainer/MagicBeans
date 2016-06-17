module MagicBeans
	module ViewHelpers
		class SVG

			include ActionView::Helpers

			attr_reader :file, :image, :options

			def initialize(file, img = nil, **opts)
				@file = file
				@image = img
				@options = opts

				prepare_options
				prepare_svg
				log
			end

			def html_tag
				image_tag path, svg_attributes
			end

			def path
				"/assets/#{Rails.application.assets.find_asset(source).try(:digest_path)}"
			end

			def fallback
				if File.exists?(fallback_path)
					return asset_path
				end

				if MagicBeans.svgable?(svg_name)
					return asset_path if generate_fallback
				end

				false
			end

			private

				def log
					if fallback
						MagicBeans.log("SVG", "Fallback Exists: #{fallback_path}")
					else
						MagicBeans.log("SVG", "Unknown SVG: #{svg_name}", true)
					end
				end

				def source
					@source ||= svg_name
				end

				def color
					@options[:color].to_s.gsub(/[^A-Z0-9]+/i, "").upcase
				end

				def svg_name
					name = file.is_a?(Symbol) ? file.to_s.dasherize : file.to_s.strip
					name.gsub! /(^("|'))|(('|")$)/, ""
					name << ".svg" unless /\.svg$/i =~ name
					name.gsub! /(\.[A-Z0-9]+)$/i, ".#{color}\\1" unless color.blank?
					name
				end

				def source_name
					name = file.is_a?(Symbol) ? file.to_s.dasherize : file.to_s.strip
					name.gsub! /(^("|'))|(('|")$)/, ""
					name << ".svg" unless /\.svg$/i =~ name
					name
				end

				def image_name
					name = image.is_a?(Symbol) ? image.to_s.dasherize : image.to_s.strip
					name.gsub! /(^("|'))|(('|")$)/, ""
					name << ".#{fallback_extension}" unless /\.[a-z]+$/i =~ name
					name
				end

				def image_fallback_path
					MagicBeans.assets.find(image_name).to_s
				end

				def prepare_svg
					if !color.blank? && !MagicBeans.assets.find(svg_name)
						# Get the svg source file and directory in which it lives
						filepath = MagicBeans.assets.find(source_name)
						filedir = File.dirname(filepath)

						# Get the svg contents
						content = File.open(filepath, "r") { |io| io.read }

						# Set the color of any path/stroke in the svg
						content.gsub! /fill=\"[^\"]+\"/, "fill=\"#{@options[:color]}\""
						content.gsub! /stroke=\"[^\"]+\"/, "stroke=\"#{@options[:color]}\""

						# Write the new svg file
						File.open(File.join(filedir, svg_name), "w") { |f| f.puts content }
					end
				end

				def svg_attributes
					options.except(:extension)
				end

				def prepare_options
					options.deep_symbolize_keys!
					options[:extension] ||= [:png, :jpg, :gif]
					options[:size] ||= nil
					options[:data] ||= {}
					options[:data][:svg] = true
					options[:data][:image] = fallback
					options[:data][:size] = fallback_size
				end

				def extensions
					@extensions ||= [@options[:extension]].flatten.compact
				end

				def fallback_extension
					[options[:extension]].flatten.first
				end

				def fallback_file
					@fallback_file ||= File.basename(fallback_path)
				end

				def fallback_path
					@fallback_path ||= (MagicBeans.assets.find(image_name) || File.join(MagicBeans.config.svg.fallback_directory, source.sub(/svg$/i, [fallback_size, fallback_extension].reject(&:blank?).join("."))))
				end

				def fallback_size
					return options[:size].to_s.gsub(/(^("|'))|(('|")$)/, "") if /\d+x\d+/ =~ options[:size].to_s
					return "#{options[:size]}x#{options[:size]}".to_s.gsub(/(^("|'))|(('|")$)/, "") if /\d+/ =~ options[:size].to_s
					options[:size].to_s.gsub /(^("|'))|(('|")$)/, ""
				end

				def asset_path
					@asset_path = "/assets/#{Rails.application.assets.find_asset(fallback_file).try(:digest_path)}"
				end

				def generate_fallback
					begin
						from = MagicBeans.assets.find(source)
						MiniMagick::Tool::Convert.new do |convert|
							convert.merge! ["-background", "none"]
							convert.merge! ["-gravity", "center"]
							if fallback_size
								convert.merge! ["-density", 1200]
								convert.merge! ["-resize", fallback_size]
								convert.merge! ["-extent", fallback_size]
							end
							convert << from
							convert << fallback_path
							convert
						end
						MagicBeans.log("SVG", "Generated #{fallback_path} from #{from}")
						true
					rescue => e
						MagicBeans.log("SVG", e, true)
						false
					end
				end
		end
	end
end
