include ActionDispatch::TestProcess

FactoryGirl.define do
	factory :bean, class: MagicBeans::Bean do
		first_name "Test"
		last_name "RSpec"
		email "test@example.com"
		phone "970-581-3387"
	end

	factory :bean_with_avatar, class: MagicBeans::Bean do
		first_name "Test"
		last_name "RSpec"
		email "test@example.com"
		phone "970-581-3387"
		avatar { fixture_file_upload(File.expand_path("../../files/1.jpg", __FILE__), "image/jpeg") }
	end
end
