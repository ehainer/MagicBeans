MagicBeans::Engine.routes.draw do
	resources :beans do
		collection do
			get :notify

			# Crop routes
			get :image
			post :crop

			# Upload routes
			post :upload
			delete :remove
		end
	end
end
