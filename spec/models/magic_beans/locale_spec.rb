require 'rails_helper'

module MagicBeans

	describe MagicBeans::Locale do

		include MagicBeans::Locale

		before(:all) { MagicBeans.config.debug = false }
		after(:all) { MagicBeans.config.debug = true }

		it "should log an error and return original interpolated text if locale is invalid" do
			MagicBeans.config.debug = false
			expect(MagicBeans.config.logger).to receive(:error).with("Locale can only contain the characters A-Z, and _ (Original Translation Text: Test)")
			__("Test", 123)
			MagicBeans.config.debug = true
		end

		it "should not translate if locale translations are disabled" do
			translator("en_TEST").destroy
			translator("en_TEST")["Test 1"] = "Test 2"

			MagicBeans.config.locale.enabled = false
			expect(__("Test 1", "en_TEST")).to eq("Test 1")

			MagicBeans.config.locale.enabled = true
			expect(__("Test 1", "en_TEST")).to eq("Test 2")
		end

		it "should write translations if not already existing" do
			translator("en_TEST").destroy
			expect(translator("en_TEST").list.length).to eq(0)

			__("Test", "en_TEST")
			expect(translator("en_TEST").list.length).to eq(1)
		end

		it "should not write translations if already exists" do
			translator("en_TEST").destroy
			expect(translator("en_TEST").list.length).to eq(0)

			__("Test", "en_TEST")
			expect(translator("en_TEST").list.length).to eq(1)

			__("Test", "en_TEST")
			expect(translator("en_TEST").list.length).to eq(1)
		end

		it "should reload the list if the translation file is modified" do
			translator("en_TEST").destroy
			expect(__("Test 1", "en_TEST")).to eq("Test 1")

			# Wait one second so the mtime will be at least 1 second different after the write operation
			sleep 1
			CSV.open(translator("en_TEST").path, "w", force_quotes: true) { |f| f.puts ["Test 1", "Test 2"] }

			expect(__("Test 1", "en_TEST")).to eq("Test 2")
		end
	end
end
