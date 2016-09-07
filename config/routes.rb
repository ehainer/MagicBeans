Rails.application.routes.draw do

	resources :magic_beans, only: [:index, :update, :create, :show] do
		uploadable :beans
		croppable :beans
	end

end
