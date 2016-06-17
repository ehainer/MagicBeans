require 'digest/md5'
require 'csv'

module MagicBeans
	module Locale

		def __(text, locale = I18n.locale, **args)
			return (text % args) unless MagicBeans.config.locale.enabled?

			begin
				@translator ||= {}
				@translator[locale] ||= Translation.new(locale)
				@translator[locale].translate text, **args
			rescue => e
				MagicBeans.log("Translation", e.message.to_s + " (Original Translation Text: #{text})", true)
				text % args
			end
		end

		class Translation

			attr_accessor :locale, :list, :last_modified

			def initialize(locale)
				@locale = locale.to_s
				load_list # Load the list of translations into a dense google hash object for retrieval
			end

			def translate(text, **args)
				phrase(text, args) % args
			end

			private

				def load_list
					@list = GoogleHashDenseRubyToRuby.new
					@last_modified = modified
					CSV.foreach(path, force_quotes: true) { |row| list[row.first] = row.last unless list.has_key?(row.first) } if File.exists?(path)
				end

				def phrase(text, args)
					load_list if modified > last_modified
					write(text) if build?
					key = phrase_key(text, args)
					Rails.cache.fetch(key) { list[text] } || text
				end

				def write(text)
					unless list.has_key?(text)
						CSV.open(path, "a", force_quotes: true) { |f| f.puts [text, text] }
						list[text] = text
					end
				end

				def path
					@path ||= Rails.root.join("config", "locales", "#{locale}.csv")
				end

				def modified
					if File.exists? path
						File.new(path).ctime.to_i
					else
						Time.now.to_i
					end
				end

				def build?
					MagicBeans.config.locale.build_environment.flatten.uniq.map(&:to_s).include?(Rails.env)
				end

				def phrase_key(text, args)
					key = Digest::MD5.hexdigest [text, locale, modified].map(&:to_s).join + args.keys.join
					"translations/phrase/#{key}"
				end

				def list_key
					key = Digest::MD5.hexdigest [locale, modified].map(&:to_s).join
					"translations/list/#{key}"
				end
		end
	end
end
