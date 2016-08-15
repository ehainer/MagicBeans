module MagicBeans
	module Notifyable

		def notifyable
			include InstanceMethods

			before_validation :validate_notifications

			after_validation :clean_notification_validation

			has_many :notifications, as: :notifyable, class_name: "MagicBeans::Notification"
		end

		module InstanceMethods

			private

				def validate_notifications
					# Find all notification records that haven't been saved yet
					self.notifications.select(&:new_record?).each do |notification|

						# Set the to value for both the email and phone, if any on this model
						notification.to self.try(:email), self.try(:phone)

						# If not valid, populate the childs error messages in this models errors object
						unless notification.valid?
							notification.errors.messages.each do |k, errors|
								errors.each { |error| self.errors.add "notifications.#{k}", error }
							end
						end
					end
				end

				def clean_notification_validation
					# Cleanup, remove the notifications key from the error messages,
					# All of the actual errors are populated into "notifications.<type>" keys above
					self.errors.delete :notifications
				end
		end
	end
end