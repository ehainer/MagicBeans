class CreateMagicBeansBeans < ActiveRecord::Migration
	def change
		create_table :magic_beans_beans do |t|
			t.string :first_name
			t.string :last_name
			t.string :email
			t.string :phone
			t.string :avatar
			t.column :attachments, :json

			t.timestamps null: false
		end
	end
end
