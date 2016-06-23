require 'rails_helper'

module MagicBeans
	describe Notification, type: :model do

		context "Email Notifications" do

			it "should send an email notification when associated model saved" do
				bean = build(:bean)
				bean.notifications.build { |n| n.email "Test" }

				expect { bean.save }.to change(ActionMailer::Base.deliveries, :size).by(1)

				expect(bean.notifications.count).to eq(1)

				expect(bean.notifications.last.to_email).to eq bean.email
			end

			it "should send an email with one or more attached files when saved" do
				bean = build(:bean)
				bean.notifications.build do |n|
					n.email "Test With Attachments" do
						attach "placeholder-1.jpg"
						attach File.open(MagicBeans.assets.find("placeholder-2.jpg"))
					end
				end

				expect { bean.save }.to change(ActionMailer::Base.deliveries, :size).by(1)

				expect(last_email.body.parts.length).to eq(3)

				expect(last_email.body.parts.collect(&:content_type)).to eq(["text/html; charset=UTF-8", "image/jpeg; filename=placeholder-1.jpg", "image/jpeg; filename=placeholder-2.jpg"])
			end

			it "should fail to save if notification email subject is blank" do
				bean = build(:bean)
				bean.notifications.build { |n| n.email nil }
				bean.save

				expect(bean).to_not be_valid

				expect(bean.errors.full_messages).to include "Notifications email subject cannot be blank"
			end

			it "should fail to save if notification email recipient is blank" do
				bean = build(:bean, email: nil)
				bean.notifications.build { |n| n.email "Test" }
				bean.save

				expect(bean).to_not be_valid

				expect(bean.errors.full_messages).to include "Notifications email recipient cannot be blank"
			end

		end

		context "SMS Notifications" do

			it "should send an sms notification when associated model saved" do
				skip
				bean = build(:bean)
				bean.notifications.build { |n| n.sms "Test" }
				bean.save

				expect(bean.notifications.last.response[:sms][0]["status"]).to eq("queued")

				expect(bean.notifications.count).to eq(1)

				expect(bean.notifications.last.to_phone).to eq bean.phone

			end

			it "should send an sms with one or more attached images when saved" do
				skip
				bean = build(:bean)
				bean.notifications.build do |n|
					n.sms "Test With Attachments" do
						attach "http://www.commercekitchen.com/wp-content/themes/heroic/img/CK_Logo_SlantedWhiteDot.png"
						attach "placeholder-1.jpg"
					end
				end
				bean.save

				expect(bean.notifications.last.response[:sms][0]["status"]).to eq("queued")

				expect(bean.notifications.count).to eq(1)

				expect(bean.notifications.last.to_phone).to eq bean.phone
			end

			it "should fail to save if notification sms message is blank" do
				bean = build(:bean)
				bean.notifications.build { |n| n.sms nil }
				bean.save

				expect(bean).to_not be_valid

				expect(bean.errors.full_messages).to include "Notifications sms message cannot be blank"
			end

			it "should fail to save if notification sms recipient is invalid" do
				skip
				bean = build(:bean)
				bean.notifications.build { |n| n.sms "Test", to: "abcdefg" }
				bean.save

				expect(bean).to_not be_valid

				expect(bean.errors.full_messages).to include "Notifications sms recipient is not a valid phone number"
			end

			it "should fail to save if notification sms recipient is blank" do
				bean = build(:bean, phone: nil)
				bean.notifications.build { |n| n.sms "Test" }
				bean.save

				expect(bean).to_not be_valid

				expect(bean.errors.full_messages).to include "Notifications sms recipient cannot be blank"
			end

		end
	end
end
