require 'rails_helper'

RSpec.describe FiguresController, type: :controller do
  let (:user) { FactoryGirl.create(:user) }
  let (:dance) { FactoryGirl.create(:dance) }
  before(:each) do
    # @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe "GET #index" do
    it 'assigns @prefs, @moves, and @mdtab' do
      dance
      get :index
      expect(assigns(:prefs)).to eq(subject.current_user.prefs)
      expect(assigns(:move_terms_and_substitutions).find {|m| m['term'] == 'swing'}).to be_present
      expect(assigns(:mdtab)['swing']).to be_present
    end
  end

  describe "GET #show" do
    # see feature specs
  end
end
