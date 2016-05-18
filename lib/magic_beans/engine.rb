require "magic_beans/view_helpers"
require "magic_beans/sass_helpers"

module MagicBeans
	class Engine < ::Rails::Engine

		initializer "magic_beans.view_helpers" do
			ActionView::Base.send :include, ViewHelpers
			ActionView::Helpers::FormBuilder.send :prepend, MagicBeans::ViewHelpers::FormBuilder
		end

		initializer "magic_beans.sass_helpers" do
			Sass::Script::Functions.send :include, SassHelpers
		end

		config.assets.precompile += %w( placeholder-1.jpg placeholder-2.jpg placeholder-3.jpg placeholder-4.jpg placeholder-5.jpg placeholder-6.jpg placeholder-7.jpg placeholder-8.jpg tinymce.css )

		config.to_prepare do
		end
	end
end
