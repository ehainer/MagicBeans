require "simplecov"
require "faker"

ENV['RAILS_ENV'] ||= "test"

SimpleCov.start do
	add_filter "/spec/"
end

require File.expand_path("../../config/environment.rb", __FILE__)
require "rspec/rails"
require "sidekiq/testing"
require "factory_girl_rails"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
	config.before(:suite) do
		["spec-svg.png", "spec-svg.323A45.png", "spec-svg.323A45.svg", "spec-svg.tif"].each do |f|
			file = File.expand_path("../files/#{f}", __FILE__)
			File.unlink(file) if File.exists?(file)
		end
		%x[bundle exec rake assets:precompile]
	end

	config.mock_with :rspec
	config.use_transactional_fixtures = false
	config.infer_base_class_for_anonymous_controllers = false
	config.order = "random"

	config.include(MagicBeansMacro)

	config.before(:each) do
		reset_email
		reset_beans
	end

	config.fixture_path = "#{File.dirname(__FILE__)}"

	config.include FactoryGirl::Syntax::Methods

	MagicBeans.config.locale.enabled = true

	MagicBeans.config.locale.build_environment = :test

	MagicBeans.config.svg.icon_directory = File.expand_path("../files", __FILE__)

	MagicBeans.config.svg.fallback_directory = File.expand_path("../files", __FILE__)

end
