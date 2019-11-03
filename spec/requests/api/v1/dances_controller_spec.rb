require 'rails_helper'

RSpec.describe Api::V1::DancesController do
  describe "GET #index" do
    it "returns json of all dances" do
      dance = FactoryGirl.create(:call_me)
      get api_v1_dances_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq([dance.to_search_result])
    end

    it 'only performs one query'

    it 'understands index and offset'

    it 'takes other dance search parameters'
  end
end
