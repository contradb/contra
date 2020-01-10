require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    let! (:admin) { FactoryGirl.create(:user, admin: true) }
    let! (:creator) { FactoryGirl.create(:user) }
    let (:other_user) { FactoryGirl.create(:user) }
    let! (:dance0) { FactoryGirl.create(:dance, user: creator, title: "dance0", publish: :off) }
    let! (:dance1) { FactoryGirl.create(:dance, user: creator, title: "dance1", publish: :link) }
    let! (:dance2) { FactoryGirl.create(:dance, user: creator, title: "dance2", publish: :all) }


    context "without login" do
      it "renderer gets @public_dances and @sketchbook_dances with searchable dances" do
        get :show, params: {id: creator.to_param}
        expect(assigns(:public_dances).to_a).to eq([dance2])
        expect(assigns(:sketchbook_dances).to_a).to eq([dance1])
      end
    end

    context "with creator login" do
      it "renderer gets @dances with searchable dances in alphabetical order" do
        dance3 = FactoryGirl.create(:dance, user: creator, title: "dance3", publish: :all)
        adance4 = FactoryGirl.create(:dance, user: creator, title: "adance4", publish: :all)
        sign_in creator
        get :show, params: {id: creator.to_param}
        expect(assigns(:public_dances).to_a).to eq([adance4, dance2, dance3])
      end
    end

    context "with user-who-is-not-creator login" do
      it "renderer gets @dances with searchable dances" do
        sign_in other_user
        get :show, params: {id: creator.to_param}
        expect(assigns(:public_dances).to_a).to eq([dance2])
      end
    end

    context "with admin login" do
      it "renderer gets @dances with visible dances in alphabetical order" do
        sign_in admin
        get :show, params: {id: creator.to_param}
        expect(assigns(:public_dances).to_a).to eq([dance2])
      end
    end
  end
end
