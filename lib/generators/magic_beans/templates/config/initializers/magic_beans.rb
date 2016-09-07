MagicBeans.setup do |config|

	# Whether to enable debug output in the browser console and terminal window
	config.debug = true

	config.base_url = ""

	# The directory that contains SVG icons
	config.svg.icon_directory = Rails.root.join("app", "assets", "images", "icon", "svg")

	# The directory where generated fallback images for SVG's should reside
	config.svg.fallback_directory = Rails.root.join("app", "assets", "images")

	# The environment(s) that svg -> png generation can occur in. Defaults to "development"
	# Can specify either a single environment or an array of environments. NOT recommended for production
	config.svg.build_environment = :development

	# List of packages that should be loaded within the app. Highly recommended that if a package
	# is not used, it should not be included, as the overhead for some packages can be large
	# Possible options:
	# :validation, :autogrow, :bubble, :calendar, :clamp, :dialog, :crop, :editable, :loadable, :map, :mask, :numeric, :placeholder, :select, :svg, :tooltip, :upload, :carousel
	config.packages = [:validation, :autogrow, :bubble, :calendar, :clamp, :dialog, :crop, :editable, :loadable, :map, :mask, :numeric, :placeholder, :select, :svg, :tooltip, :upload, :carousel]

	# When to validate each field. Possible options are "submit" (default) or "blur"
	# "submit" only validates form fields when the form is submitted, while
	# "blur" will validate as soon as the field loses focus
	config.js.validate_trigger = :submit

	# How validation error messages are shown. Possible options are "global" (default) or "progressive"
	# "global" will display all validation error messages relating to the field all at once, while
	# "progressive" will only show one validation error message at a time, in the same order as each validate-* class is defined
	config.js.validate_style = :global

	# Anything set on the js config is inserted into a JSON object that is fed directly
	# into the Bean JS class's config, making it available via `Bean.Config.get('some_random_config_field')`
	# config.js.some_random_config_field = "nonsense"

	# The directory where dropzone uploads will be temporarily stored.
	# Files will be distributed throughout this directory as needed
	config.upload.temp_directory = Rails.root.join("uploads")

	# Whether or not translation is enabled
	config.locale.enabled = true

	# Which locales to build translation files for
	config.locale.locales << :en

	# In what environments will translation generation occur. Recommended to keep this as development (default)
	config.locale.build_environment << :development

	# Twilio account id number
	config.twilio.account_sid = ""

	# Twilio authentication token
	config.twilio.auth_token = ""

	# Default from phone number. Must be the number provided by Twilio
	config.twilio.from = ""

	# The offset used in generating base64 encoded ids. A higher number means larger ids (i.e. - "7feIds" instead of "6f"),
	# but can potentially produce large base64 encoded ids
	# DON'T change this number once records whose id's are being encoded exist in the database
	# as all decoded ids will be incorrect
	config.crypt.offset = 262144

	# The location of the blacklist, words that should NOT be permitted in the form of generated ids
	# Each word should be on it's own line, and only contain [A-Z], no spaces, dashes, underscores, or numbers
	# Each word is automatically matched against it's literal, case-insensitive, and l33t spellings, with dashes
	# and underscores optionally preceding/following each character.
	# i.e. - the blacklist word "toke" will match [toke, tOKE, 7oke, t0k3, t-o-k-e, -t0--k3--, etc...]
	config.crypt.blacklist = Rails.root.join("config", "locales", "blacklist.txt")

	# The seed used to randomize base 64 characters. Once set, it should NOT EVER be changed.
	# Doing so will result in incorrect decoded ids, followed by large crowds with pitchforks and torches
	config.crypt.seed = ""

end
