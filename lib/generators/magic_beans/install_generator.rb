class MagicBeans::InstallGenerator < Rails::Generators::Base
	source_root File.expand_path('../../../../', __FILE__)

	def copy_javascripts
		directory "app/assets/javascripts", Rails.root.join("app", "assets", "javascripts")
	end

	def copy_stylesheets
		directory "app/assets/stylesheets", Rails.root.join("app", "assets", "stylesheets")
	end

	def copy_icons
		directory "app/assets/images/icons", Rails.root.join("app", "assets", "images", "icons")
	end

	def copy_initializer
		copy_file "lib/generators/magic_beans/templates/config/initializers/magic_beans.rb", Rails.root.join("config", "initializers", "magic_beans.rb")
	end

	def copy_locale
		copy_file "lib/generators/magic_beans/templates/config/locales/blacklist.txt", Rails.root.join("config", "locales", "blacklist.txt")
	end
end
