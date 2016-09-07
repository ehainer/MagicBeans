Rails.application.routes.draw do

	resources :magicbeans do
		uploadable :beans
		croppable :beans
	end

end
