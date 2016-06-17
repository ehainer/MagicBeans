module MagicBeans
	class Notification < ActiveRecord::Base

		belongs_to :notifyable, polymorphic: true

		after_initialize :setup

		before_save :validate, on: :create

		before_save :deliver, on: :create

		attr_accessor :to, :from

		def email(subject, **args, &block)
			@email.permit!
			@email.notification = self
			@email.to = args[:to] || to
			@email.from = args[:from] || from
			@email.subject = subject
			@email.vars = args
			@email.instance_exec &block if block_given?
		end

		def sms(message, **args, &block)
			@sms.permit!
			@sms.notification = self
			@sms.to = args[:to] || to
			@sms.from = args[:from] || from || MagicBeans.config.twilio.from
			@sms.message = message
			@sms.instance_exec &block if block_given?
		end

		class SMS

			attr_accessor :to, :from, :message, :attachments, :response, :notification

			def initialize
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
				@to ||= notification.notifyable.try(:phone)
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
					puts e.to_yaml
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

			def initialize
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
				@to ||= notification.notifyable.try(:email)
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
					if @sms.deliverable?
						@sms.deliver
						self.request[:sms] = @sms.request
						self.response[:sms] = @sms.response
					end

					if @email.deliverable?
						@email.deliver
						self.request[:email] = @email.request
						self.response[:email] = @email.response
					end

				rescue MagicBeans::Error => e
					self.errors.add :base, error
				end
			end

			def validate
				@sms.before_deliver
				@email.before_deliver

				(@sms.errors + @email.errors).each { |error| self.errors.add :base, error }
			end

			def setup
				@email ||= Email.new
				@sms ||= SMS.new

				self.request = {}
				self.response = {}
			end

	end
end
