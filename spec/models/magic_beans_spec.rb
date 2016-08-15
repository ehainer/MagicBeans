require 'rails_helper'

module MagicBeans

	describe MagicBeans do

		it "should be buildable if the asset exists and current environment is in the svg build environments" do
			MagicBeans.config.svg.build_environment = :test
			expect(MagicBeans.config.svg.is_buildable?).to eq(true)

			MagicBeans.config.svg.build_environment = nil
			expect(MagicBeans.config.svg.is_buildable?).to eq(false)
		end

		it "should correctly return whether or not a package is enabled" do
			MagicBeans.config.packages = []
			expect(MagicBeans.has_package?(:upload)).to eq(false)

			MagicBeans.config.packages = [:upload]
			expect(MagicBeans.has_package?(:upload)).to eq(true)
		end

		it "should log to STDOUT when debugging" do
			MagicBeans.config.debug = true
			expect { MagicBeans.log("Debug", "Test") }.to output(/Test/).to_stdout
			expect { MagicBeans.log("Debug", "Test", true) }.to output(/Test/).to_stdout

			MagicBeans.config.debug = false
			expect { MagicBeans.log("Debug", "Test") }.to_not output(/Test/).to_stdout
			expect { MagicBeans.log("Debug", "Test", true) }.to_not output(/Test/).to_stdout
		end
	end
end
