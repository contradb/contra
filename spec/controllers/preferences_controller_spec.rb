require 'rails_helper'


describe PreferencesController do
  describe 'GET #edit' do
    it 'works' do
      get :edit, params: {}
      expect(assigns(:preferences_form)).to be_a(PreferencesForm)
    end
  end

  describe 'PATCH #update' do
    it 'works' do
      patch :update, params: {:preferences_form => {name: 'foobar'}}
      expect(assigns(:preferences_form)).to be_a(PreferencesForm)
    end
  end
end
