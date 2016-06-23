class CreateMagicBeansUploadTemps < ActiveRecord::Migration
	def change
		create_table :magic_beans_upload_temps do |t|
			t.string :name
			t.string :upload
			t.string :resource

			t.timestamps null: false
		end
	end
end
