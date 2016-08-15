class MagicBeans::BeansController < ApplicationController

	layout "magic_beans/application"

	before_action :init_objects

	uploadable MagicBeans::Bean

	croppable MagicBeans::Bean

	def on_crop_success(resource)
		redirect_to(resource, notice: __("CROP SUCCESS")) and return true
	end

	def on_crop_failure(resource)
		redirect_to(resource, alert: __("CROP FAILURE")) and return true
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

	def get_proc_resource
		MagicBeans::Bean.new(first_name: "PROC")
	end

	def get_symbol_resource
		MagicBeans::Bean.new(first_name: "SYMBOL")
	end

	private

		def bean_params
			params.require(:bean).permit(:first_name, :last_name, :email, :avatar, attachments: [])
		end

		def init_objects
			@options = 20.times.map { |i| [Faker::Name.name, i] }
		end

end
