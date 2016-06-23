FactoryGirl.define do
	factory :bean, class: MagicBeans::Bean do
		first_name "John"
		last_name "Smith"
		email "john@example.com"
		phone "970-581-3387"
	end
end
