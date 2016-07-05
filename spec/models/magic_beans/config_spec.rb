require 'rails_helper'

module MagicBeans

	describe MagicBeans::Config do

		let(:config) { MagicBeans::Config.new }

		it "should return html safe json when to_json called" do
			expect { JSON.parse(config.to_json) }.to_not raise_error
		end
	end
end
