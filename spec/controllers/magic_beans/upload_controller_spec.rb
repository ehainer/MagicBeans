require 'rails_helper'

class UploadController < ActionController::Base
	include MagicBeans::Upload

	def index
		@bean = MagicBeans::Bean.new(first_name: "ASSIGNS")
		render nothing: true
	end

	def create
		@bean = MagicBeans::Bean.new
		render nothing: true
	end

	def update
		@bean = MagicBeans::Bean.new
		render nothing: true
	end

	def get_proc_resource
		MagicBeans::Bean.new(first_name: "PROC")
	end

	def get_symbol_resource
		MagicBeans::Bean.new(first_name: "SYMBOL")
	end
end

module MagicBeans
	describe UploadController, type: :controller do

		Rails.application.routes.draw do
			post "upload" => "upload#upload"

			get "index" => "upload#index"
			post "create" => "upload#create"
			patch "update" => "upload#update"
		end

		let(:avatar) { fixture_file_upload("files/1.jpg", "image/jpeg") }
		let(:attachment1) { fixture_file_upload("files/2.jpg", "image/jpeg") }
		let(:attachment2) { fixture_file_upload("files/3.jpg", "image/jpeg") }
		let(:invalid) { fixture_file_upload("files/invalid.log", "text/plain") }

		before(:each) do
			MagicBeans::UploadTemp.destroy_all
		end

		it "should raise an argument error if the resource class is not defined" do
			expect { controller.class.uploadable }.to raise_error(ArgumentError)
		end

		it "should raise an argument error if the resource class does not exist" do
			expect { controller.class.uploadable "::RandomUnknownNonExistentClass" }.to raise_error(ArgumentError)
		end

		it "should correctly fetch the resource taking into account a :resource option" do
			get :index

			controller.class.uploadable MagicBeans::Bean, resource: Proc.new { |c| c.get_proc_resource }
			expect(controller.uploader.resource).to have_attributes(first_name: "PROC")

			controller.class.uploadable MagicBeans::Bean, resource: :get_symbol_resource
			expect(controller.uploader.resource).to have_attributes(first_name: "SYMBOL")

			controller.class.uploadable MagicBeans::Bean, resource: nil
			expect(controller.uploader.resource).to have_attributes(first_name: "ASSIGNS")
		end

		it "should return errors if any uploaded files are not valid, as determined by uploader" do
			controller.class.uploadable MagicBeans::Bean

			params = { controller.uploader.resource_param_name => { avatar: invalid, attachments: [attachment1, attachment2] } }

			post :upload, params

			parsed_body = JSON.parse(response.body)

			expect(parsed_body).to have_key("errors")
			expect(parsed_body["errors"]).to have_key("avatar")
			expect(parsed_body["errors"]["avatar"].length).to eq(1)
			expect(MagicBeans::UploadTemp.count).to eq(0)
		end

		it "should temporarily store uploaded files" do

			controller.class.uploadable MagicBeans::Bean

			params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

			post :upload, params

			parsed_body = JSON.parse(response.body)

			expect(parsed_body).to have_key("uploads")
			expect(MagicBeans::UploadTemp.count).to eq(3)
			expect(parsed_body["uploads"][controller.uploader.resource_param_name.to_s].length).to eq(3)
			expect(parsed_body["uploads"][controller.uploader.resource_param_name.to_s]).to all(be > 0)

			expect(MagicBeans::UploadTemp.all).to all(have_attributes(resource: "MagicBeans::Bean"))
			expect(MagicBeans::UploadTemp.all).to all(have_attributes(name: "avatar").or have_attributes(name: "attachments"))
		end

		it "should not process uploads if options :except includes current controller action" do
			controller.class.uploadable MagicBeans::Bean

			upload_params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }
			post :upload, upload_params

			parsed_body = JSON.parse(response.body)

			commit_params = { controller.uploader.resource_param_name => { commit: parsed_body["uploads"][controller.uploader.resource_param_name.to_s] } }
			post :create, commit_params
			expect(controller.uploader.processable?).to eq(true)

			controller.class.uploadable MagicBeans::Bean, except: :create
			post :create, commit_params
			expect(controller.uploader.processable?).to eq(false)
		end

		it "should correctly respond to uploadable? if routing to upload action and uploads are present" do
			controller.class.uploadable MagicBeans::Bean

			post :upload, { bean: [] }
			expect(controller.uploader.uploadable?).to eq(false)

			params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

			post :upload, params
			expect(controller.uploader.uploadable?).to eq(true)
		end

		it "should respond with HTTP status 500 if errors are present, or 200 if no errors" do
			controller.class.uploadable MagicBeans::Bean

			params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }
			post :upload, params
			expect(response.status).to eq(200)

			params = { controller.uploader.resource_param_name => { avatar: invalid, attachments: [attachment1, attachment2] } }
			post :upload, params
			expect(response.status).to eq(500)
		end

		it "should commit uploads when created" do
			controller.class.uploadable MagicBeans::Bean

			upload_params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

			post :upload, upload_params

			parsed_body = JSON.parse(response.body)

			commit_params = { controller.uploader.resource_param_name => { commit: parsed_body["uploads"][controller.uploader.resource_param_name.to_s] } }

			post :create, commit_params
		end
	end
end
