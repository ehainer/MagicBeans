module MagicBeansMacro
	def last_email
		ActionMailer::Base.deliveries.last
	end

	def reset_email
		ActionMailer::Base.deliveries = []
	end

	def reset_beans
		MagicBeans::Bean.destroy_all
	end
end