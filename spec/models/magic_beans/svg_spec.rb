require 'rails_helper'

module MagicBeans

	describe MagicBeans::SVG do

		before(:all) { MagicBeans.config.debug = false }

		after(:all) { MagicBeans.config.debug = true }

		before(:each) { $0 = "rails" }

		it "should not have a fallback if not buildable and fallback file does not exist" do
			MagicBeans.config.svg.build_environment = :null

			svg = MagicBeans::SVG.new(:missing)
			expect(svg.svg_asset_path).to eq(false)
		end

		it "should generate a fallback image if the specified svg exists and is buildable" do
			MagicBeans.config.svg.build_environment = :test

			png = File.expand_path("../../../files/spec-svg.png", __FILE__)
			File.unlink(png) if File.exists?(png)

			expect(File.exists?(png)).to eq(false)

			svg = MagicBeans::SVG.new(:spec_svg)

			expect(File.exists?(png)).to eq(true)
		end

		it "should have an svg digest name if called from rake" do
			MagicBeans.config.svg.build_environment = :test

			png = File.expand_path("../../../files/spec-svg.png", __FILE__)
			File.unlink(png) if File.exists?(png)

			$0 = "rake"

			svg = MagicBeans::SVG.new(:spec_svg)
			expect(svg.svg_asset_path).to match(/^spec\-svg\-[0-9a-z]+\.svg/)
		end

		it "should log an svg error if unable to generate a fallback image from the provided file" do
			MagicBeans.config.svg.build_environment = :test

			expect(MagicBeans.config.logger).to receive(:error).with(/failed with error/)
			svg = MagicBeans::SVG.new(:invalid)
		end

		it "should format the source file name" do
			svg = MagicBeans::SVG.new(:spec_svg)
			expect(svg.svg).to eq("spec-svg.svg")

			svg = MagicBeans::SVG.new("spec-svg.svg")
			expect(svg.svg).to eq("spec-svg.svg")

			svg = MagicBeans::SVG.new("invalid.log")
			expect(svg.svg).to eq("invalid.log.svg")
		end

		it "should create a colorized svg if a :color option is provided and the svg does not already exist" do
			MagicBeans.config.svg.build_environment = :test

			svg_color = File.expand_path("../../../files/spec-svg.323A45.svg", __FILE__)
			png_color = File.expand_path("../../../files/spec-svg.323A45.png", __FILE__)

			File.unlink(svg_color) if File.exists?(svg_color)
			File.unlink(png_color) if File.exists?(png_color)

			expect(File.exists?(svg_color)).to eq(false)
			expect(File.exists?(png_color)).to eq(false)

			svg = MagicBeans::SVG.new(:spec_svg, color: "#323A45")

			expect(File.exists?(svg_color)).to eq(true)
			expect(File.exists?(png_color)).to eq(true)
		end

		it "should have and accept an array of file extensions which to match the image name against" do
			svg = MagicBeans::SVG.new(:spec_svg)
			expect(svg.extensions).to eq(["png", "jpg", "gif"])

			svg = MagicBeans::SVG.new(:spec_svg, nil, extension: [:tif, :eps])
			expect(svg.extensions).to eq(["tif", "eps"])
		end

		it "should log unknown svg if fallback cannot be found" do
			MagicBeans.config.svg.build_environment = :test

			expect(MagicBeans.config.logger).to receive(:error).with(/Unknown SVG/)
			svg = MagicBeans::SVG.new(:missing)
		end
	end
end
