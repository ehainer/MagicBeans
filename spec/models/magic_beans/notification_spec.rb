require 'rails_helper'

module MagicBeans
	describe MagicBeans::Notification, type: :model do

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
						attach "1.jpg"
						attach File.open(MagicBeans.assets.find("2.jpg"))
					end
				end

				expect { bean.save }.to change(ActionMailer::Base.deliveries, :size).by(1)

				expect(last_email.body.parts.length).to eq(3)

				expect(last_email.body.parts.collect(&:content_type)).to eq(["text/html; charset=UTF-8", "image/jpeg; filename=1.jpg", "image/jpeg; filename=2.jpg"])
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

			it "should have a non-empty request after delivering email" do
				bean = build(:bean)
				bean.notifications.build { |n| n.email "Test" }
				bean.save

				expect(bean.notifications.last.email_instance.request.length).to eq(1)
			end

		end

		context "SMS Notifications" do

			it "should send an sms notification when associated model saved" do
				#skip "Sends an SMS message"
				bean = build(:bean)
				bean.notifications.build { |n| n.sms "Test" }
				bean.save

				expect(bean.notifications.last.response[:sms][0]["status"]).to eq("queued")

				expect(bean.notifications.count).to eq(1)

				expect(bean.notifications.last.to_phone).to eq bean.phone

			end

			it "should send an sms with one or more attached images when saved" do
				#skip "Sends an SMS message"
				bean = build(:bean)
				bean.notifications.build do |n|
					n.sms "Test With Attachments" do
						attach "https://images.unsplash.com/photo-1436891678271-9c672565d8f6?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&s=19a603025f5f82e92731fadf96172acf"
						attach "1.jpg"
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
				#skip "Sends an SMS message"
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

			it "should have a non-empty request after delivering sms" do
				#skip "Sends an SMS message"
				bean = build(:bean)
				bean.notifications.build { |n| n.sms "Test" }
				bean.save

				expect(bean.notifications.last.sms_instance.request.length).to eq(1)
			end

			it "should increase the size of the sms request array by number of messages - 1 when delivered" do
				#skip "Sends an SMS message"
				bean = build(:bean)
				notification = bean.notifications.build do |n|
					n.sms "Test With Attachment" do
						attach "https://images.unsplash.com/photo-1436891620584-47fd0e565afb?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&s=df6386c2e327ae9dbc7e5be0bef4e1d6"
						attach "2.jpg"
					end
				end

				expect { bean.save }.to change(notification.sms_instance.request, :length).from(0).to(2)
			end

			it "should return false if phone number is not valid" do
				bean = build(:bean)
				notification = bean.notifications.build do |n|
					n.sms "Test", to: "abc123"
				end

				expect(notification.sms_instance.valid_phone?).to eq(false)
			end

		end
	end
end
