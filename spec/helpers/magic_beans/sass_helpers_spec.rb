require 'rails_helper'

module MagicBeans

	describe MagicBeans::SassHelpers do

		include MagicBeans::SassHelpers

		before(:all) { MagicBeans.config.debug = false }

		after(:all) { MagicBeans.config.debug = true }

		it "should respond with css background properties given an svg source" do
			MagicBeans.config.svg.build_environment = :test

			png = File.expand_path("../../../files/spec-svg.png", __FILE__)
			File.unlink(png) if File.exists?(png)

			svg = svg_icon("spec-svg")

			expect(svg.to_s).to match(/^url/)
			expect(svg.to_s).to match(/spec\-svg\-[a-z0-9]+\.png/)
			expect(svg.to_s).to match(/spec\-svg\-[a-z0-9]+\.svg/)
		end

		it "should respond with none as a background when the svg source does not exist" do
			svg = svg_icon(:missing)
			expect(svg.to_s).to eq("none")
		end
	end
end
