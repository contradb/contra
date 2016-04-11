require 'rails_helper'
# random flailing trying to make logins work:
# require 'fake_user_helper'
# include Warden::Test::Helpers
# Warden.test_mode!

RSpec.describe DancesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Dance. As you add validations to Dance, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {title: 'Flappy the TestDance',
     choreographer: FactoryGirl.create(:choreographer),
     start_type: 'improper',
     figures_json: "[]"}
  }

  let(:invalid_attributes) {
    {asdfasdf: 56,
     start_type: '',
     figures_json: "{'whatever': 'no'}",
     user: FactoryGirl.create(:user),
     choreographer: nil}
  }


  describe "GET #index" do
    it "assigns all dances as @dances" do
      dance = Dance.create! valid_attributes
      get :index, {}
      expect(assigns(:dances)).to eq([dance])
    end
  end

  describe "GET #show" do
    it "assigns the requested dance as @dance" do
      dance = Dance.create! valid_attributes
      get :show, {:id => dance.to_param}
      expect(assigns(:dance)).to eq(dance)
    end
  end

  include Devise::TestHelpers
  # include_context 'user is signed in'

  describe "GET #new" do
    it "assigns a new dance as @dance" do
      pending "can't figure out how to login"
      get :new, {}
      expect(assigns(:dance)).to be_a_new(Dance)
    end
  end

  describe "GET #edit" do
    it "assigns the requested dance as @dance" do
      @request.env['HTTP_REFERER'] = 'http://yahoo.com' # set it to whatever nonsense just to not get an error.
      dance = Dance.create! valid_attributes
      get :edit, {:id => dance.to_param}
      expect(assigns(:dance)).to eq(dance)
    end
  end





  describe "POST #create" do
    context "with valid params" do
      it "creates a new Dance" do
        pending "can't figure out how to login"
        expect {
          post :create, {:dance => valid_attributes}
        }.to change(Dance, :count).by(1)
      end

      it "assigns a newly created dance as @dance" do
        pending "can't figure out how to login"
        post :create, {:dance => valid_attributes}
        expect(assigns(:dance)).to be_a(Dance)
        expect(assigns(:dance)).to be_persisted
      end

      it "redirects to the created dance" do
        pending "can't figure out how to login"
        post :create, {:dance => valid_attributes}
        expect(response).to redirect_to(Dance.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved dance as @dance" do
        pending "can't figure out how to login"
        post :create, {:dance => invalid_attributes}
        expect(assigns(:dance)).to be_a_new(Dance)
      end

      it "re-renders the 'new' template" do
        pending "can't figure out how to login"
        post :create, {:dance => invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested dance" do
        pending "can't figure out how to login"
        dance = Dance.create! valid_attributes
        put :update, {:id => dance.to_param, :dance => new_attributes}
        dance.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested dance as @dance" do
        dance = Dance.create! valid_attributes
        put :update, {:id => dance.to_param, :dance => valid_attributes}
        expect(assigns(:dance)).to eq(dance)
      end

      it "redirects to the dance" do
        pending "can't figure out how to login"
        dance = Dance.create! valid_attributes
        put :update, {:id => dance.to_param, :dance => valid_attributes}
        expect(response).to redirect_to(dance)
      end
    end

    context "with invalid params" do
      # I can't mark these pending, because then the test would succeed for the wrong reason.
      # it "assigns the dance as @dance" do
      #   dance = Dance.create! valid_attributes
      #   put :update, {:id => dance.to_param, :dance => invalid_attributes}
      #   expect(assigns(:dance)).to eq(dance)
      # end
      #
      # it "re-renders the 'edit' template" do
      #   dance = Dance.create! valid_attributes
      #   put :update, {:id => dance.to_param, :dance => invalid_attributes}
      #   expect(response).to render_template("edit")
      # end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested dance" do
      pending "can't figure out how to login"
      # login_as FactoryGirl.create(:user, name: "Jane"), scope: :user
      @request.env['HTTP_REFERER'] = '/dances'
      dance = Dance.create! valid_attributes
      expect {
        delete :destroy, {:id => dance.to_param}
      }.to change(Dance, :count).by(-1)
      logout
    end

    it "redirects to the dances list" do
      pending "can't figure out how to login"
      @request.env['HTTP_REFERER'] = '/dances'
      dance = Dance.create! valid_attributes
      delete :destroy, {:id => dance.to_param}
      expect(response).to redirect_to(dances_url)
    end
  end
end
