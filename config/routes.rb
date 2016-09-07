Rails.application.routes.draw do

	namespace :magic_beans do
		resources :beans do
			uploadable :beans
			croppable :beans
		end
	end

end
