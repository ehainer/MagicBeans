class CreateMagicBeansNotifications < ActiveRecord::Migration
	def change
		create_table :magic_beans_notifications do |t|
			t.string :notifyable_type
			t.integer :notifyable_id
			t.string :method
			t.string :to_phone
			t.string :to_email
			t.json :request
			t.json :response

			t.timestamps null: false
		end
	end
end
