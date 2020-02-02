require 'rails_helper'

RSpec.describe Api::V1::DancesController do
  describe "POST #index" do
    let (:now) { DateTime.now }
    let (:headers) { { "content_type" => "application/json" } }
    it "returns json of all dances" do
      dance = FactoryGirl.create(:call_me)
      post(api_v1_dances_path, params: {}, headers: headers)
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
                   "publish"=>"everywhere",
                   "matching_figures_html"=>"whole dance"}
                 ]})
    end

    it 'understands count and offset' do
      pageSize = 4
      pages = 3
      dances = (pages*pageSize).times.map do |i|
        FactoryGirl.create(:dance, title: "dance-#{i}", created_at: now - i.hours)
      end
      pages.times do |pageIndex|
        pageSize.times do |rowIndex|
          params = {count: pageSize, offset: pageIndex*pageSize}
          post(api_v1_dances_path, params: params, headers: headers)
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

    it 'heeds sorting' do
      dances = "caB".chars.each_with_index.map do |char, i|
        FactoryGirl.create(:dance, title: char*3, created_at: now - i.hours)
      end
      post(api_v1_dances_path, params: {sort_by: 'titleA'}, headers: headers)
      dances_received = JSON.parse(response.body)['dances']
      aaaBBBccc = ['aaa', 'BBB', 'ccc']
      expect(aaaBBBccc).to eq(dances.dup.sort_by {|d| d.title.downcase }.map(&:title))
      expect(dances_received.map{|json| json['title']}).to eq(aaaBBBccc)
    end

    it 'heeds filter' do
      dances = [:box_the_gnat_contra, :dance].map {|name| FactoryGirl.create(name)}
      box_the_gnat = dances.first
      post(api_v1_dances_path, params: {filter: ['figure', 'box the gnat']}, headers: headers)
      dances_received = JSON.parse(response.body)['dances']
      expect(dances_received.map {|d| d['title']}).to eq([box_the_gnat.title])
    end

    it 'calls FilterDances.filter_dances the currently logged in user' do
      with_login do |user|
        expect(FilterDances).to receive(:filter_dances).with(anything, hash_including(user: user))
        post(api_v1_dances_path, params: {}, headers: headers)
      end
    end

    it 'only performs one sql query'
  end
end
