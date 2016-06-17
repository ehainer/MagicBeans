module MagicBeans
	class MultipleFileUploader

		attr_accessor :model, :mounted_as

		def initialize(model, mounted_as)
			@model = model
			@mounted_as = mounted_as
			@uploader ||= ::AttachmentUploader.new(model, mounted_as)
		end

		def store_dir
			File.join MagicBeans.config.upload.temp_directory, mounted_as.to_s, model.id.to_s
		end

		def method_missing(method_sym, *arguments, &block)
			@uploader.send method_sym, *arguments, &block
		end

		def self.method_missing(method_sym, *arguments, &block)
			::AttachmentUploader.send method_sym, *arguments, &block
		end
	end
end
