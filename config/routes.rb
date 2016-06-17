MagicBeans::Engine.routes.draw do
	resources :upload, only: :create
end
