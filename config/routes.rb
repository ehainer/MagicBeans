Rails.application.routes.draw do

	resources :magic_beans do
		uploadable :beans
		croppable :beans
	end

	#namespace :magic_beans do
	#	resources :beans, only: [:show, :create, :update]
#
#	#	scope "beans" do
#	#	end
	#end
end
