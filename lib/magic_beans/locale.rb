require "digest"
require "csv"
require "google_hash"

module MagicBeans
	module Locale

		def __(text, locale = I18n.locale, **args)
			return (text % args) unless MagicBeans.config.locale.enabled?

			begin
				raise "Locale can only contain the characters A-Z, and _" unless locale.to_s =~ /^[A-Z_]+$/i
				translator(locale).translate text, **args
			rescue => e
				MagicBeans.log("Translation", e.message.to_s + " (Original Translation Text: #{text})", true)
				text % args
			end
		end

		def translator(locale = I18n.locale)
			@translators ||= {}
			@translators[locale.to_s] ||= Translation.new(locale)
			@translators[locale.to_s]
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

			def []=(text, translation)
				unless list.has_key?(text)
					CSV.open(path, "a", force_quotes: true) { |f| f.puts [text, translation] }
					list[text] = translation
				end
			end

			def destroy
				File.unlink(path) if File.exists?(path)
				load_list
			end

			def path
				@path ||= Rails.root.join("config", "locales", "#{locale}.csv")
			end

			private

				def write(text)
					unless list.has_key?(text)
						CSV.open(path, "a", force_quotes: true) { |f| f.puts [text, text] }
						list[text] = text
						MagicBeans.log("Translation", "Added translation for text '#{text}'")
					end
				end

				def load_list
					@list = ::GoogleHashDenseRubyToRuby.new
					@last_modified = modified
					Rails.cache.delete_matched("translations/phrase") if Rails.cache.respond_to?(:delete_matched)
					CSV.foreach(path, force_quotes: true) { |row| list[row.first] = row.last unless list.has_key?(row.first) } if File.exists?(path)
				end

				def phrase(text, args)
					load_list if modified > last_modified
					write(text) if build?
					key = phrase_key(text, args)
					Rails.cache.fetch(key) { list[text] } || text
				end

				def modified
					if File.exists? path
						File.mtime(path).to_i
					else
						Time.now.to_i
					end
				end

				def build?
					[MagicBeans.config.locale.build_environment].flatten.map(&:to_s).uniq.include?(Rails.env.to_s)
				end

				def phrase_key(text, args)
					key = Digest::SHA256.hexdigest [text, locale, modified].map(&:to_s).join + args.map { |k,v| "#{k}#{v}" }.join
					"translations/phrase/#{key}"
				end
		end
	end
end
