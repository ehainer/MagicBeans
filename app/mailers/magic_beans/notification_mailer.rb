class MagicBeans::NotificationMailer < ApplicationMailer
	default from: "info@commercekitchen.com"

	def notify(mail_args, var_args = {}, attachment_args = {})
		# Make all passed in variables instance variables so they can be used in the template
		var_args.each { |name, value| instance_variable_set "@#{name}", value }

		# Add all of the attachments
		attachment_args.each { |name, file| attachments[name] = File.read(file) }

		mail mail_args
	end
end
