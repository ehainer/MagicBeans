class MagicBeans::Bean < ActiveRecord::Base

	mount_uploader :avatar, MagicBeans::AvatarUploader

	mount_uploaders :attachments, MagicBeans::AttachmentUploader

	notifyable

end
