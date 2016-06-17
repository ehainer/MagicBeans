require "sass/rails"

module MagicBeans

	extend ActiveSupport::Autoload

	autoload :ViewHelpers

	autoload :SassHelpers

	class Engine < ::Rails::Engine
		isolate_namespace MagicBeans

		initializer "magic_beans.engine", before: :load_config_initializers do |app|
			Rails.application.routes.append do
				mount MagicBeans::Engine, at: "/magicbeans"
			end
		end

		initializer "magic_beans.append_migrations" do |app|
			unless app.root.to_s.match root.to_s
				config.paths["db/migrate"].expanded.each do |expanded_path|
					app.config.paths["db/migrate"] << expanded_path
				end
			end
		end

		initializer "magic_beans.view_helpers" do
			ActionView::Base.send :include, ViewHelpers
			ActionView::Helpers::FormBuilder.send :prepend, MagicBeans::ViewHelpers::FormBuilder
		end

		initializer "magic_beans.locale" do
			ActionController::Base.send :include, ::MagicBeans::Locale
			ActiveRecord::Base.send :include, ::MagicBeans::Locale
		end

		initializer "magic_beans.sass_helpers" do
			::Sass::Script::Functions.send :include, ::MagicBeans::SassHelpers
		end

		config.generators do |g|
			g.test_framework :rspec, fixture: false
			g.fixture_replacement :factory_girl, dir: 'spec/factories'
			g.assets false
			g.helper false
		end

		config.assets.precompile += %w( bean.js.erb tinymce.css placeholder-1.jpg placeholder-2.jpg placeholder-3.jpg placeholder-4.jpg placeholder-5.jpg placeholder-6.jpg placeholder-7.jpg placeholder-8.jpg )
	end
end
