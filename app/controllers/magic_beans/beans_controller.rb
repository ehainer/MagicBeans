class MagicBeans::BeansController < ApplicationController

	include MagicBeans::Upload

	include MagicBeans::Crop

	before_action :init_objects

	uploadable MagicBeans::Bean

	crop_for :avatar

	def on_crop_success(resource)
		render text: resource.first_name + " OH BOY!"
	end

	def index
		@bean = MagicBeans::Bean.new
	end

	def show
		@bean = MagicBeans::Bean.find(params[:id])
		render :index
	end

	def create
		@bean = MagicBeans::Bean.new(bean_params)
		if @bean.save
			redirect_to @bean, notice: __("Bean created successfully")
		else
			flash[:alert] = @bean.errors.full_messages
			render :index
		end
	end

	def update
		@bean = MagicBeans::Bean.find(params[:id])
		if @bean.update(bean_params)
			redirect_to @bean, notice: __("Bean saved successfully")
		else
			flash[:alert] = @bean.errors.full_messages
			render :index
		end
	end

	def notify
		@bean = MagicBeans::Bean.new(first_name: "John", last_name: "Smith", email: "eric@commercekitchen.com", phone: "970-581-3387")

		@bean.notifications.build do |n|
			n.sms __("Welcome, %{name}!", name: @bean.first_name)
			n.email __("Welcome, %{name}", name: @bean.first_name), body: __("Login to the new site"), subtext: "Yadda yadda yadda"
		end

		@bean.save

		render json: { request: notification.request, response: notification.response }
	end

	private

		def bean_params
			params.require(:bean).permit(:first_name, :last_name, :email, :avatar, attachments: [])
		end

		def init_objects
			@options = 20.times.map { |i| [Faker::Name.name, i] }
		end
end
