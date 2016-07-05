require 'rails_helper'

class TestController < ApplicationController; end

module MagicBeans
	describe MagicBeans::BeansController, type: :controller do

		routes { MagicBeans::Engine.routes }

		let(:avatar) { fixture_file_upload("files/1.jpg", "image/jpeg") }
		let(:attachment1) { fixture_file_upload("files/2.jpg", "image/jpeg") }
		let(:attachment2) { fixture_file_upload("files/3.jpg", "image/jpeg") }
		let(:invalid) { fixture_file_upload("files/invalid.log", "text/plain") }
		let!(:bean) { FactoryGirl.create(:bean) }
		let!(:test_controller) { TestController.new }

		before(:each) { MagicBeans::UploadTemp.destroy_all }

		before(:all) { MagicBeans.config.debug = false }
		after(:all) { MagicBeans.config.debug = false }

		it "should render with an instance of MagicBeans::Bean" do
			get :show, { id: bean.to_param }

			expect(assigns(:bean)).to be_a(MagicBeans::Bean)
			expect(assigns(:bean).first_name).to eq("Test")
			expect(assigns(:bean).last_name).to eq("RSpec")
			expect(assigns(:bean).email).to eq("test@example.com")
			expect(response).to render_template(:index)
		end

		it "should redirect to the MagicBeans::Bean when created" do
			post :create, { bean: { first_name: "Test", last_name: "Test", email: "test@example.com" } }
			expect(response).to redirect_to(bean_url(assigns(:bean)))

			post :create, { bean: { first_name: nil } }
			expect(response).to render_template(:index)
		end

		it "should redirect to the MagicBeans::Bean when updated" do
			patch :update, { id: bean.to_param, bean: { first_name: "Test", last_name: "Test", email: "test@example.com" } }
			expect(response).to redirect_to(bean_url(assigns(:bean)))

			patch :update, { id: bean.to_param, bean: { first_name: nil } }
			expect(response).to render_template(:index)
		end

		it "should return a MagicBeans::Bean instance from get_proc_resource" do
			expect(controller.get_proc_resource).to be_a_new(MagicBeans::Bean)
		end

		it "should return a MagicBeans::Bean instance from get_symbol_resource" do
			expect(controller.get_symbol_resource).to be_a_new(MagicBeans::Bean)
		end

		context "Upload" do

			it "should raise an argument error if the upload resource class is not defined" do
				expect { controller.class.uploadable }.to raise_error(ArgumentError)
			end

			it "should raise an argument error if the upload resource class does not exist" do
				expect { controller.class.uploadable "::RandomUnknownNonExistentClass" }.to raise_error(ArgumentError)
			end

			it "should correctly fetch the upload resource taking into account a :resource option" do
				get :index

				controller.class.uploadable MagicBeans::Bean, resource: Proc.new { |c| c.get_proc_resource }
				expect(controller.uploader.resource).to have_attributes(first_name: "PROC")

				controller.class.uploadable MagicBeans::Bean, resource: :get_symbol_resource
				expect(controller.uploader.resource).to have_attributes(first_name: "SYMBOL")

				controller.class.uploadable MagicBeans::Bean, resource: nil
				expect(controller.uploader.resource).to have_attributes(first_name: nil)
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
				expect(controller.uploader.commitable?).to eq(true)

				controller.class.uploadable MagicBeans::Bean, except: :create
				post :create, commit_params
				expect(controller.uploader.commitable?).to eq(false)
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

			it "should remove uploads when remove params includes temp upload id" do
				controller.class.uploadable MagicBeans::Bean

				upload_params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

				post :upload, upload_params

				parsed_body = JSON.parse(response.body)

				expect(MagicBeans::UploadTemp.count).to eq(3)

				remove_params = { controller.uploader.resource_param_name => { remove: { temp: parsed_body["uploads"][controller.uploader.resource_param_name.to_s] } } }

				post :create, remove_params

				expect(MagicBeans::UploadTemp.count).to eq(0)
			end

			it "should remove uploads when remove params includes upload hash" do
				controller.class.uploadable MagicBeans::Bean

				upload_params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

				post :upload, upload_params

				parsed_body = JSON.parse(response.body)

				expect(MagicBeans::UploadTemp.count).to eq(3)

				commit_params = { controller.uploader.resource_param_name => { first_name: "Test", last_name: "Test", email: "test@example.com", commit: parsed_body["uploads"][controller.uploader.resource_param_name.to_s] } }

				post :create, commit_params

				remove_params = { id: assigns(controller.uploader.resource_param_name).to_param, controller.uploader.resource_param_name => { remove: { file: [], temp: [] } } }

				remove_params[controller.uploader.resource_param_name][:remove][:file] << Digest::SHA256.hexdigest("#{controller.uploader.resource.class.name.underscore}_#{controller.uploader.resource.id}_avatar_#{controller.uploader.resource.avatar.file.filename}")

				assigns(controller.uploader.resource_param_name).attachments.each do |upload|
					remove_params[controller.uploader.resource_param_name][:remove][:file] << Digest::SHA256.hexdigest("#{controller.uploader.resource.class.name.underscore}_#{controller.uploader.resource.id}_attachments_#{upload.file.filename}")
				end

				patch :update, remove_params

				expect(controller.uploader.resource.avatar.file).to be_nil
				expect(controller.uploader.resource.attachments).to be_blank
			end

			it "should remove selected uploads only" do
				controller.class.uploadable MagicBeans::Bean

				upload_params = { controller.uploader.resource_param_name => { avatar: avatar, attachments: [attachment1, attachment2] } }

				post :upload, upload_params

				parsed_body = JSON.parse(response.body)

				expect(MagicBeans::UploadTemp.count).to eq(3)

				commit_params = { controller.uploader.resource_param_name => { first_name: "Test", last_name: "Test", email: "test@example.com", commit: parsed_body["uploads"][controller.uploader.resource_param_name.to_s] } }

				post :create, commit_params

				remove_params = { id: assigns(controller.uploader.resource_param_name).to_param, controller.uploader.resource_param_name => { remove: { file: [], temp: [] } } }

				remove_params[controller.uploader.resource_param_name][:remove][:file] << Digest::SHA256.hexdigest("#{controller.uploader.resource.class.name.underscore}_#{controller.uploader.resource.id}_avatar_#{controller.uploader.resource.avatar.file.filename}")
				remove_params[controller.uploader.resource_param_name][:remove][:file] << Digest::SHA256.hexdigest("#{controller.uploader.resource.class.name.underscore}_#{controller.uploader.resource.id}_attachments_#{controller.uploader.resource.attachments.first.file.filename}")

				patch :update, remove_params

				expect(controller.uploader.resource.avatar.file).to be_nil
				expect(controller.uploader.resource.attachments.length).to eq(1)
			end

		end

		context "Crop" do

			it "should raise an argument error if the crop resource class is not defined" do
				expect { test_controller.class.croppable }.to raise_error(MagicBeans::Crop::ArgumentError)
			end

			it "should raise an argument error if the crop resource class does not exist" do
				expect { test_controller.class.croppable "::RandomUnknownNonExistentClass" }.to raise_error(MagicBeans::Crop::ArgumentError)
			end

			it "should correctly fetch the crop resource taking into account a :resource option" do
				get :index

				controller.class.croppable MagicBeans::Bean, resource: Proc.new { |c| c.get_proc_resource }
				expect(controller.cropper.resource).to have_attributes(first_name: "PROC")

				controller.class.croppable MagicBeans::Bean, resource: :get_symbol_resource
				expect(controller.cropper.resource).to have_attributes(first_name: "SYMBOL")

				controller.class.croppable MagicBeans::Bean, resource: nil
				assigns(:bean).first_name = "ASSIGNS"
				expect(controller.cropper.resource).to have_attributes(first_name: "ASSIGNS")

				controller.class.croppable MagicBeans::Bean, resource: nil
				controller.remove_instance_variable("@bean")
				expect(controller.cropper.resource).to be_a_new(MagicBeans::Bean)
			end

			it "should raise an invalid mount error if the specified crop type could not be found on the resource" do
				controller.class.croppable MagicBeans::Bean

				expect { patch :crop, { id: bean.to_param, crop: { type: nil, x: 0, y: 0, width: 100, height: 100 } } }.to raise_error(MagicBeans::Crop::InvalidMount)
			end

			it "should crop the image" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean

				original_modified = File.mtime(bean.avatar.file.path)
				original_size = bean.avatar.file.size

				# Wait just so the modified time will be different
				sleep 2

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response).to redirect_to(bean)

				expect(original_modified).to be < File.mtime(bean.avatar.file.path)
				expect(original_size.to_i).to be > bean.avatar.file.size
			end

			it "should respond with json of image versions" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean

				patch :crop, { format: :json, id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				parsed_body = JSON.parse(response.body)

				expect(parsed_body.keys.map(&:to_s)).to eq(bean.avatar.versions.keys.map(&:to_s) + ["avatar"])
			end

			it "should respond with the specified image url" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean

				get :image, { type: :avatar, id: bean.to_param }

				parsed_body = JSON.parse(response.body)

				expect(parsed_body["url"]).to eq(bean.avatar.url)
			end

			it "should respond with the default image url if no image exists" do
				controller.class.croppable MagicBeans::Bean

				get :image, { type: :avatar, id: bean.to_param }

				parsed_body = JSON.parse(response.body)

				expect(parsed_body["url"]).to eq(bean.avatar.url)
			end

			it "should redirect to the resource after cropping successful" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response).to redirect_to(bean)
			end

			it "should run the success callback if one provided in the form of a symbol" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean, success: :on_crop_success

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response.body).to eq("<html><body>You are being <a href=\"#{bean_url(bean)}\">redirected</a>.</body></html>")
				expect(response.flash[:notice]).to eq("CROP SUCCESS")
			end

			it "should run the success callback if one provided in the form of a proc" do
				bean.update(avatar: avatar)

				controller.class.croppable MagicBeans::Bean, success: Proc.new { |resource| controller.redirect_to(resource, notice: "CROP SUCCESS") }

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response.body).to eq("<html><body>You are being <a href=\"#{bean_url(bean)}\">redirected</a>.</body></html>")
				expect(response.flash[:notice]).to eq("CROP SUCCESS")
			end

			it "should redirect to the resource with an alert flash after cropping failure" do
				bean.update(avatar: avatar)

				bean.first_name = nil
				bean.save(validate: false)

				controller.class.croppable MagicBeans::Bean

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response.flash[:alert]).to_not be_blank
				expect(response).to redirect_to(bean)
			end

			it "should run the failure callback if one provided in the form of a symbol" do
				bean.update(avatar: avatar)

				bean.first_name = nil
				bean.save(validate: false)

				controller.class.croppable MagicBeans::Bean, failure: :on_crop_failure

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response.body).to eq("<html><body>You are being <a href=\"#{bean_url(bean)}\">redirected</a>.</body></html>")
				expect(response.flash[:alert]).to eq("CROP FAILURE")
			end

			it "should run the failure callback if one provided in the form of a proc" do
				bean.update(avatar: avatar)

				bean.first_name = nil
				bean.save(validate: false)

				controller.class.croppable MagicBeans::Bean, failure: Proc.new { |resource| controller.redirect_to(resource, alert: "CROP FAILURE") }

				patch :crop, { id: bean.to_param, crop: { type: :avatar, x: 0, y: 0, width: 100, height: 100 } }

				expect(response.body).to eq("<html><body>You are being <a href=\"#{bean_url(bean)}\">redirected</a>.</body></html>")
				expect(response.flash[:alert]).to eq("CROP FAILURE")
			end

			it "should have false for the success callback if none defined" do
				controller.class.croppable MagicBeans::Bean

				expect(controller.cropper.success).to eq(false)
			end

			it "should have false for the failure callback if none defined" do
				controller.class.croppable MagicBeans::Bean

				expect(controller.cropper.failure).to eq(false)
			end
		end
	end
end
