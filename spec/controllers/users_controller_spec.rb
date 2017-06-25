require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    let! (:user_admin) { FactoryGirl.create(:user, admin: true) }
    let! (:user_b) { FactoryGirl.create(:user) }
    let! (:dance_b2) { FactoryGirl.create(:dance, user: user_b, title: "dance b2", publish: true) }
    let! (:dance_b1) { FactoryGirl.create(:dance, user: user_b, title: "dance b1", publish: false) }

    context "without login" do
      it "renderer gets @dances with visible dances in alphabetical order" do
        get :show, params: {id: user_b.to_param}
        expect(assigns(:dances).to_a).to eq([dance_b2])
      end
    end

    context "with login" do
      it "renderer gets @dances with visible dances in alphabetical order" do
        sign_in user_b
        get :show, params: {id: user_b.to_param}
        expect(assigns(:dances).to_a).to eq([dance_b1,dance_b2])
      end
    end

    context "with admin login" do
      it "renderer gets @dances with visible dances in alphabetical order" do
        sign_in user_admin
        get :show, params: {id: user_b.to_param}
        expect(assigns(:dances).to_a).to eq([dance_b1,dance_b2])
      end
    end
  end
end
