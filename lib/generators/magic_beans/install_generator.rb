class MagicBeans::InstallGenerator < Rails::Generators::Base
	source_root File.expand_path('../../../../', __FILE__)

	def copy_assets
		directory "app/assets/javascripts", Rails.root.join("app", "assets", "javascripts")
		directory "app/assets/stylesheets", Rails.root.join("app", "assets", "stylesheets")
		directory "app/assets/images/icon", Rails.root.join("app", "assets", "images", "icon")
	end

	def copy_config
		copy_file "lib/generators/magic_beans/templates/config/initializers/magic_beans.rb", Rails.root.join("config", "initializers", "magic_beans.rb")
		copy_file "lib/generators/magic_beans/templates/config/locales/blacklist.txt", Rails.root.join("config", "locales", "blacklist.txt")
	end

	def copy_controllers
		copy_file "app/controllers/magic_beans/beans_controller.rb", Rails.root.join("app", "controllers", "magic_beans", "beans_controller.rb")
	end

	def copy_views
		directory "app/views/layouts/magic_beans", Rails.root.join("app", "views", "layouts", "magic_beans")
		copy_file "app/views/magic_beans/beans/index.html.erb", Rails.root.join("app", "views", "magic_beans", "beans", "index.html.erb")
	end
end
