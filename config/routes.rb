Rails.application.routes.draw do
	root "beans#index"

	resources :beans, only: [:show, :create, :update]

	scope "beans" do
		uploadable :beans
		croppable :beans
	end
end
