class CreateMagicBeansUploadTemps < ActiveRecord::Migration
	def change
		create_table :magic_beans_upload_temps do |t|
			t.string :key
			t.string :name
			t.string :mount
			t.string :resource
			t.boolean :multiple

			t.timestamps null: false
		end
	end
end
