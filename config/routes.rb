Rails.application.routes.draw do

	resources :magic_beans do
		uploadable :beans
		croppable :beans
	end

end
