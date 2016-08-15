require "sass/rails"
require "carrierwave"
require "twilio-ruby"

module MagicBeans

	extend ActiveSupport::Autoload

	autoload :ViewHelpers

	autoload :SassHelpers

	autoload :FormBuilder

	autoload :Routes

	class Engine < ::Rails::Engine
		isolate_namespace MagicBeans

#		initializer "magic_beans.engine", before: :load_config_initializers do |app|
#			Rails.application.routes.append do
#				mount MagicBeans::Engine, at: "/magicbeans"
#			end
#		end

		initializer "magic_beans.append_migrations" do |app|
			unless app.root.to_s.match root.to_s
				config.paths["db/migrate"].expanded.each do |expanded_path|
					app.config.paths["db/migrate"] << expanded_path
				end
			end
		end

		initializer "magic_beans.view_helpers" do
			ActionView::Base.send :include, ::MagicBeans::ViewHelpers
			ActionView::Helpers::FormBuilder.send :prepend, ::MagicBeans::FormBuilder
		end

		initializer "magic_beans.sass_helpers" do
			Sass::Script::Functions.send :include, ::MagicBeans::SassHelpers
		end

		initializer "magic_beans.locale" do
			ActionController::Base.send :include, ::MagicBeans::Locale
			ActiveRecord::Base.send :include, ::MagicBeans::Locale
			ActionView::Base.send :include, ::MagicBeans::Locale
		end

		initializer "magic_beans.id" do
			ActiveRecord::Base.send :extend, ::MagicBeans::Idable
		end

		initializer "magic_beans.notifications" do
			ActiveRecord::Base.send :extend, ::MagicBeans::Notifyable
		end

		initializer "magic_beans.controllers" do
			ActionController::Base.send :extend, ::MagicBeans::Crop
			ActionController::Base.send :extend, ::MagicBeans::Upload
		end

		initializer "magic_beans.routes" do
			ActionDispatch::Routing::Mapper.send :include, ::MagicBeans::Routes
		end

		initializer "magic_beans.assets", after: :load_config_initializers do
			config.assets.paths << MagicBeans.config.svg.icon_directory
			config.assets.paths << MagicBeans.config.svg.fallback_directory
		end

		config.generators do |g|
			g.test_framework :rspec, fixture: false
			g.fixture_replacement :factory_girl, dir: 'spec/factories'
		end

		config.assets.precompile += %w( bean.css bean.js tinymce.css 1.jpg 2.jpg 3.jpg 4.jpg 5.jpg 6.jpg 7.jpg 8.jpg 9.jpg 10.jpg 11.jpg 12.jpg 13.jpg 14.jpg 15.jpg 16.jpg 17.jpg 18.jpg 19.jpg 20.jpg 21.jpg 22.jpg 23.jpg )
	end
end
