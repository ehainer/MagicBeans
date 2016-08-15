require 'rails_helper'

module MagicBeans

	describe MagicBeans::Idable do

		let(:bean) { FactoryGirl.create(:bean) }

		it "should raise record not found error if the encrypted record id could not be found" do
			param = bean.to_param

			expect(MagicBeans::Bean.find(param)).to be_a(MagicBeans::Bean)

			bean.destroy

			expect { MagicBeans::Bean.find(param) }.to raise_error(ActiveRecord::RecordNotFound)
		end

		it "should be false if not exists?" do

			expect(MagicBeans::Bean.exists?("-100000")).to eq(false)

		end

		it "should be able to destroy one or more records" do
			5.times { MagicBeans::Bean.create(first_name: "Test", last_name: "RSpec", email: "test@example.com") }

			expect(MagicBeans::Bean.destroy(MagicBeans::Bean.first.to_param).length).to eq(1)

			to_destroy = MagicBeans::Bean.all.map(&:to_param)

			expect(MagicBeans::Bean.destroy(to_destroy).length).to eq(4)
			expect(MagicBeans::Bean.count).to eq(0)
		end

		it "should be able to delete one or more records" do
			5.times { MagicBeans::Bean.create(first_name: "Test", last_name: "RSpec", email: "test@example.com") }

			expect(MagicBeans::Bean.delete(MagicBeans::Bean.first.to_param)).to eq(1)

			to_delete = MagicBeans::Bean.all.map(&:to_param)

			expect(MagicBeans::Bean.delete(to_delete)).to eq(4)
			expect(MagicBeans::Bean.count).to eq(0)
		end

		it "should properly respond to exists?" do
			bean = MagicBeans::Bean.create(first_name: "Test", last_name: "RSpec", email: "test@example.com")

			expect(MagicBeans::Bean.exists?(bean.to_param)).to eq(true)
		end

	end

end