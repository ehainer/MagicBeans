require 'rails_helper'

module MagicBeans

	describe MagicBeans::Config do

		let(:config) { MagicBeans::Config.new }

		it "should return html safe json when to_json called" do
			expect { JSON.parse(config.to_json) }.to_not raise_error
		end

		it "should return the value of a given secret key if called as a method" do
			expect(config.secrets.secret_key_base).to_not be_blank
		end
	end
end
