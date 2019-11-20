require 'rails_helper'

RSpec.describe Api::V1::DancesController do
  describe "GET #index" do
    it "returns json of all dances" do
      dance = FactoryGirl.create(:call_me)
      dance.reload
      get api_v1_dances_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq([{"id"=>dance.id,
                                                "title"=>dance.title,
                                                "choreographer_id"=>dance.choreographer_id,
                                                "choreographer_name"=>dance.choreographer.name,
                                                "formation" => dance.start_type,
                                                "hook" => dance.hook,
                                                "user_id" => dance.user_id,
                                                "user_name" => dance.user.name,
                                                "created_at"=>dance.created_at.as_json,
                                                "updated_at"=>dance.updated_at.as_json,
                                                "publish"=>"everyone",
                                                "matching_figures_html"=>"whole dance"}])
    end

    it 'only performs one query'

    it 'understands index and offset'

    it 'takes other dance search parameters'
  end
end
