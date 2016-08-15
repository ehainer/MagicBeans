require 'rails_helper'

class TestHelper < ActionView::Base; end

module MagicBeans

	describe MagicBeans::FormBuilder do
		let(:helper) { TestHelper.new }
		let(:resource) { FactoryGirl.build :bean_with_avatar }
		let(:builder) { ::ActionView::Helpers::FormBuilder.new :bean, resource, helper, {} }

		it "should generate a file field" do
			field = builder.upload_field :avatar

			expect(field).to match(/data\-upload="\/magicbeans\/beans\/upload"/)
			expect(field).to match(/name="bean\[avatar\]"/)
		end

		it "should attach all previously uploaded image data if :preserve option is true" do
			field = builder.upload_field :avatar, data: { preserve: true }
			file_data = field.match(/data\-files="([^"]+)"/)[1]
			json_data = JSON.parse(CGI.unescapeHTML(file_data.to_str))

			expect(field).to match(/data\-preserve="true"/)
			expect(json_data.values.first["name"]).to eq("1.jpg")
		end
	end
end
