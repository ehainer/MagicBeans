Rails.application.configure do
	config.assets.paths = [
		File.expand_path("../../../spec/files", __FILE__),
		File.expand_path("../../../generator/template/assets/icons/svg", __FILE__),
		File.expand_path("../../../generator/template/assets/icons/png", __FILE__)
	]

	config.serve_static_files = true

	config.static_cache_control = "public, max-age=3600"

	config.assets.compress = true

	config.assets.compile = true

	config.assets.precompile += %w( *.svg *.png *.jpg invalid.log )

	config.assets.digest = true
end