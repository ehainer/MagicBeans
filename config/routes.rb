MagicBeans::Engine.routes.draw do

	resources :beans

	scope :beans do
		uploadable :beans
		croppable :beans
	end

end
