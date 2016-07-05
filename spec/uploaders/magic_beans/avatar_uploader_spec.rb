require 'rails_helper'

module MagicBeans

	describe MagicBeans::AvatarUploader do

		let(:uploader) { MagicBeans::AvatarUploader.new }

		it "should return html safe json when to_json called" do
			expect(uploader.default_url).to match(/^\/assets\/default.*$/)
		end
	end
end
