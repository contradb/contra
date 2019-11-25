require 'rails_helper'

RSpec.describe Api::V1::DancesController do
  describe "GET #index" do
    it "returns json of all dances" do
      dance = FactoryGirl.create(:call_me)
      dance.reload
      get api_v1_dances_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body))
        .to eq({
                 "numberSearched" => 1,
                 "numberMatching" => 1,
                 "dances" =>
                 [{"id"=>dance.id,
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
                   "matching_figures_html"=>"whole dance"}
                 ]})
    end

    it 'understands count and offset' do
      pageSize = 4
      pages = 3
      now = DateTime.now
      dances = (pages*pageSize).times.map {|i| FactoryGirl.create(:dance, title: "dance-#{i}", created_at: now - i.hours)}
      pages.times do |pageIndex|
        pageSize.times do |rowIndex|
          get api_v1_dances_path(count: pageSize, offset: pageIndex*pageSize)
          expect(response).to have_http_status(200)
          rendered = JSON.parse(response.body)
          expect(rendered['numberMatching']).to eq(12)
          expect(rendered['dances'].length).to eq(pageSize)
          d1 = dances[pageSize * pageIndex + rowIndex]
          d2 = rendered.dig('dances', rowIndex)
          expect(d1.id).to eq(d2['id'])
        end
      end
    end


    it 'only performs one query'

    it 'takes other dance search parameters'
  end
end
