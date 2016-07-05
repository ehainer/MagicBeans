require 'rails_helper'

module MagicBeans

	describe MagicBeans::ViewHelpers do

		include MagicBeans::ViewHelpers

		before(:all) { MagicBeans.config.debug = false }

		after(:all) { MagicBeans.config.debug = true }

		it "should return an img tag to the specified svg file" do
			MagicBeans.config.svg.build_environment = :test

			png = File.expand_path("../../../files/spec-svg.png", __FILE__)
			File.unlink(png) if File.exists?(png)

			tag = svg_tag(:spec_svg)

			expect(tag).to match(/^<img/)
			expect(tag).to match(/data\-svg="true"/)
			expect(tag).to match(/data\-image="\/assets\/spec\-svg\-[a-z0-9]+\.png"/)
			expect(tag).to match(/src="\/assets\/spec\-svg\-[a-z0-9]+\.svg"/)
		end
	end
end
