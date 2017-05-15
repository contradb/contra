require 'rails_helper'

RSpec.describe DancesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Dance. As you add validations to Dance, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {title: 'Flappy the TestDance',
     choreographer_name: 'Albacore Tuner',
     start_type: 'improper',
     figures_json: "[]",
     publish: true}
  }

  let(:invalid_attributes) {
    {asdfasdf: 56,
     start_type: '',
     figures_json: "[]",
     user: FactoryGirl.create(:user),
     choreographer_name: 'no'}
  }


  describe "GET #index" do
    let (:admonsterator) { FactoryGirl.create(:user, admin: true) }
    let (:user_a) { FactoryGirl.create(:user) }
    let (:user_b) { FactoryGirl.create(:user) }
    let! (:dance_b1) { FactoryGirl.create(:dance, user: user_b, title: "dance b1", publish: false) }
    let! (:dance_b2) { FactoryGirl.create(:dance, user: user_b, title: "dance b2", publish: true) }
    let! (:dance_a1) { FactoryGirl.create(:dance, user: user_a, title: "dance a1", publish: false) }
    let! (:dance_a2) { FactoryGirl.create(:dance, user: user_a, title: "dance a2", publish: true) }

    context "without login" do
      it "assigns public dances as alphabeticized @dances" do
        get :index, {}
        expect(assigns(:dances)).to eq([dance_a2, dance_b2])
      end
    end

    context "with login" do
      it "assigns public dances as alphabeticized @dances" do
        # hacky login
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user_a

        get :index, {}
        expect(assigns(:dances)).to eq([dance_a1, dance_a2, dance_b2])
      end
    end

    context "with admin login" do
      it "assigns public dances as alphabeticized @dances" do
        # can't make rspec any_instnace stubs work, grump
        # later: hey! why are we testing unit-tested internals of the scope in our controller tests? Howsabout we just verify we call the scope?
        # later still: because mocking scopes is brittle and hard. Or at any rate hard-er than just calling through. 

        # hacky login
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in admonsterator

        get :index, {}
        expect(admonsterator.admin?).to be(true)
        expect(assigns(:dances).pluck(:title)).to eq([dance_a1, dance_a2, dance_b1, dance_b2].map &:title)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested dance as @dance" do
      dance = FactoryGirl.create(:dance)
      get :show, {:id => dance.to_param}
      expect(assigns(:dance)).to eq(dance)
    end

    it "refuses to show a private dance, instead redirecting back and giving a warning" do
      dance = FactoryGirl.create(:dance, publish: false)
      @request.env['HTTP_REFERER'] = '/'
      get :show, {:id => dance.to_param}
      expect(response).to redirect_to '/'
      expect(flash[:notice]).to eq('this dance has not been published')
    end
  end


  describe "GET #new" do
    login_user
    it "assigns a new dance as @dance" do
      get :new, {}
      expect(assigns(:dance)).to be_a_new(Dance)
    end
  end

  describe "GET #edit" do
    login_user
    it "assigns the requested dance as @dance" do
      @request.env['HTTP_REFERER'] = 'http://yahoo.com' # set it to whatever nonsense just to not get an error.
      dance = FactoryGirl.create(:dance)
      get :edit, {:id => dance.to_param}
      expect(assigns(:dance)).to eq(dance)
    end
  end

  describe "POST #create" do
    login_user
    context "with valid params" do
      it "creates a new Dance" do
        expect {post :create, {:dance => valid_attributes}}.to change(Dance, :count).by(1)
      end

      it "assigns a newly created dance as @dance" do
        post :create, {:dance => valid_attributes}
        expect(assigns(:dance)).to be_a(Dance)
        expect(assigns(:dance)).to be_persisted
      end

      it "redirects to the created dance" do
        post :create, {:dance => valid_attributes}
        expect(response).to redirect_to(Dance.last)
      end

      it "saves attributes" do
        post :create, {:dance => valid_attributes}
        dance = Dance.last
        expect(dance.title).to eq(valid_attributes[:title])
        expect(dance.choreographer_name).to eq(valid_attributes[:choreographer_name])
        expect(dance.start_type).to eq(valid_attributes[:start_type])
        expect(dance.figures_json).to eq(valid_attributes[:figures_json])
        expect(dance.publish).to eq(valid_attributes[:publish])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved dance as @dance" do
        post :create, {:dance => invalid_attributes}
        expect(assigns(:dance)).to be_a_new(Dance)
      end

      it "re-renders the 'new' template" do
        post :create, {:dance => invalid_attributes}
        expect(response).to render_template("new")
      end

      it "does not save a dance" do
        expect {post :create, {:dance => invalid_attributes}}.to change(Dance, :count).by(0)
      end
    end
  end

  describe "PUT #update" do
    login_user
    context "with valid params" do
      let(:dance) { FactoryGirl.create(:dance) }
      let(:new_attributes) { {choreographer_name: 'Abe Baker', start_type: 'four face four'} }
      before(:each) { @request.env['HTTP_REFERER'] = dance_url(dance) }

      xit "updates the requested dance" do
        put :update, {:id => dance.to_param, :dance => new_attributes}
        dance.reload
        expect(dance.start_type).to eq('four face four')
        expect(dance.choreographer.name).to eq('Abe Baker')
      end

      it "assigns the requested dance as @dance" do
        put :update, {:id => dance.to_param, :dance => valid_attributes}
        expect(assigns(:dance)).to eq(dance)
      end

      it "redirects to the dance" do
        put :update, {:id => dance.to_param, :dance => valid_attributes}
        expect(response).to redirect_to(dance)
      end
    end

    context "with invalid params" do
      login_user
      # I can't mark these pending, because then the test would succeed for the wrong reason.
      # it "assigns the dance as @dance" do
      #   dance = FactoryGirl.create(:dance)
      #   put :update, {:id => dance.to_param, :dance => invalid_attributes}
      #   expect(assigns(:dance)).to eq(dance)
      # end
      #
      # it "re-renders the 'edit' template" do
      #   dance = FactoryGirl.create(:dance)
      #   put :update, {:id => dance.to_param, :dance => invalid_attributes}
      #   expect(response).to render_template("edit")
      # end
    end
  end

  describe "DELETE #destroy" do
    login_user
    xit "destroys the requested dance" do
      @request.env['HTTP_REFERER'] = '/dances'
      dance = FactoryGirl.create(:dance)
      expect {delete :destroy, {:id => dance.to_param}}.to change(Dance, :count).by(-1)
    end

    it "redirects to the dances list" do
      @request.env['HTTP_REFERER'] = '/dances'
      dance = FactoryGirl.create(:dance)
      delete :destroy, {:id => dance.to_param}
      expect(response).to redirect_to(dances_url)
    end
  end
end
