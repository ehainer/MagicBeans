class MagicBeans::Bean < ActiveRecord::Base

	mount_uploader :avatar, MagicBeans::AvatarUploader

	mount_uploaders :attachments, MagicBeans::AttachmentUploader

	notifyable

	encrypted_id

	validates_presence_of :first_name

	validates_presence_of :last_name

	validates_presence_of :email

end
