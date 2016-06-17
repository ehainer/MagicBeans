module MagicBeans
	class Notification < ActiveRecord::Base

		belongs_to :notifyable, polymorphic: true

		after_initialize :setup

		before_save :validate, on: :create

		before_save :deliver, on: :create

		attr_accessor :to, :from

		def email(subject, **args, &block)
			# Flags Email as deliverable?
			email_instance.permit!
			# Set the recipient. If value of args[:to] is nil value of the notification's :to will be used,
			# or finally, `notifyable.email` will be tried automatically
			email_instance.to = args[:to] || to
			# Set the sender. If value of args[:from] is nil and the notifications :from is nil,
			# ultimately the default from in the mailer will be used
			email_instance.from = args[:from] || from
			# Set the email subject
			email_instance.subject = subject
			# All args are passed in as email args, which will be converted to instance variables within NotificationMailer
			email_instance.vars = args
			# If a block is provided, allow calls to methods like `attach`, `method`, and `mailer`
			email_instance.instance_exec &block if block_given?
		end

		def sms(message, **args, &block)
			# Flags SMS as deliverable?
			sms_instance.permit!
			# Set the recipient. If value of args[:to] is nil value of `notifyable.phone` will be tried automatically
			sms_instance.to = args[:to]
			# Set the sender. If value of args[:from] is nil the default twilio from phone number will be used
			sms_instance.from = args[:from] || MagicBeans.config.twilio.from
			# Set the SMS message
			sms_instance.message = message
			# If a block is provided, allow calls to methods like `attach`
			sms_instance.instance_exec &block if block_given?
		end

		class SMS

			attr_accessor :to, :from, :message, :attachments, :response, :notification

			def initialize(**args)
				args.each { |k, v| send "#{k}=", v }
				@attachments ||= []
				@permitted = false
				@result = {}
			end

			def request
				@result[:request] ||= []
			end

			def response
				@result[:response] ||= []
			end

			def before_deliver
				# Try once more to fetch a to phone number, only at this point is notifyable saved, and it's data accessible
				@to ||= notification.try(:notifyable).try(:phone)
				notification.to_phone = @to
			end

			def deliver
				begin
					if attachments.length > 1
						begin
							client.messages.create({ from: from_formatted, to: to_formatted, media_url: attachments.shift }.compact)
							request << Rack::Utils.parse_nested_query(client.last_request.body)
							response << JSON.parse(client.last_response.body)
						end until attachments.length == 1
					end

					client.messages.create({ from: from_formatted, to: to_formatted, body: message, media_url: attachments.shift }.compact)
					request << Rack::Utils.parse_nested_query(client.last_request.body)
					response << JSON.parse(client.last_response.body)
				rescue Twilio::REST::RequestError => e
					raise MagicBeans::Error.new(e.message)
				end
			end

			def attach(url)
				if url.starts_with? "http"
					attachments << url
				else
					attachments << MagicBeans.config.base_url + ActionController::Base.helpers.asset_url(url)
				end
			end

			def deliverable?
				@permitted
			end

			def permit!
				@permitted = true
			end

			def errors
				output = []
				return output unless @permitted
				output << "SMS recipient cannot be blank" if to.blank?
				output << "SMS sender cannot be blank" if from.blank?
				output << "SMS message cannot be blank" if message.blank?
				output
			end

			private

				def to_formatted
					format to
				end

				def from_formatted
					format from
				end

				def format(input)
					# If already in the correct format, just return it
					return input if input =~ /^\+[0-9]+$/

					begin
						# Try to format the number via Twilio's api
						number = lookup.phone_numbers.get input
						number.phone_number
					rescue => e
						# If anything happens, just try with what was provided
						input
					end
				end

				def client
					@client ||= Twilio::REST::Client.new MagicBeans.config.twilio.account_sid, MagicBeans.config.twilio.auth_token
				end

				def lookup
					@lookup ||= Twilio::REST::LookupsClient.new MagicBeans.config.twilio.account_sid, MagicBeans.config.twilio.auth_token
				end
		end

		class Email

			attr_accessor :to, :from, :subject, :vars, :attachments, :notification

			def initialize(**args)
				args.each { |k, v| send "#{k}=", v }
				@vars ||= {}
				@attachments ||= {}
				@mailer_class = "NotificationMailer"
				@mailer_method = "notify"
				@permitted = false
				@result = {}
			end

			def request
				@result[:request] ||= []
			end

			def response
				@result[:response] ||= []
			end

			def before_deliver
				# Try once more to fetch a to email address, only at this point is notifyable saved, and it's data accessible
				@to ||= notification.try(:notifyable).try(:email)
				notification.to_email = @to
			end

			def deliver
				request << { to: to, from: from, subject: subject }.compact.merge(vars: vars).merge(attachments: attachments)
				mail = mailer.to_s.classify.constantize.send method, { to: to, from: from, subject: subject }.compact, vars, attachments
				mail.deliver_later!
			end

			def attach(file, name = nil)
				name = File.basename(file) if name.blank?
				path = file

				if file.is_a?(File)
					path = file.path
					file.close
				end

				attachments[name] = path
			end

			def mailer(klass = nil)
				@mailer_class = klass || @mailer_class
			end

			def method(meth = nil)
				@mailer_method = meth || @mailer_method
			end

			def deliverable?
				@permitted
			end

			def permit!
				@permitted = true
			end

			def errors
				output = []
				return output unless @permitted
				output << "Email recipient cannot be blank" if to.blank?
				output << "Email subject cannot be blank" if subject.blank?
				output
			end
		end

		private

			def deliver
				return if self.errors.any?

				begin
					if sms_instance.deliverable?
						sms_instance.deliver
						self.request[:sms] = sms_instance.request
						self.response[:sms] = sms_instance.response
					end

					if email_instance.deliverable?
						email_instance.deliver
						self.request[:email] = email_instance.request
						self.response[:email] = email_instance.response
					end

				rescue MagicBeans::Error => e
					self.errors.add :base, error
				end
			end

			def validate
				sms_instance.before_deliver if sms_instance.deliverable?
				email_instance.before_deliver if email_instance.deliverable?

				(sms_instance.errors + email_instance.errors).each { |error| self.errors.add :base, error }
			end

			def email_instance
				@email ||= Email.new(notification: self)
			end

			def sms_instance
				@sms ||= SMS.new(notification: self)
			end

			def setup
				# Set the request and response data to a blank hash, more info will be populated in each
				# when the `deliver` method is called on SMS or Email instance
				self.request = {}
				self.response = {}
			end

	end
end
