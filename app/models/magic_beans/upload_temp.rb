module MagicBeans
	class UploadTemp < ActiveRecord::Base

		encrypted_id

		mount_uploader :upload, MagicBeans::UploadUploader
	end
end
