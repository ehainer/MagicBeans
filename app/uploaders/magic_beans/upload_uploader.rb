class MagicBeans::UploadUploader < CarrierWave::Uploader::Base

	# Choose what kind of storage to use for this uploader:
	storage :file
	# storage :fog

	# Override the directory where uploaded files will be stored.
	# This is a sensible default for uploaders that are meant to be mounted:
	def store_dir
		"magic_beans/upload/tmp/#{model.id}"
	end
end
