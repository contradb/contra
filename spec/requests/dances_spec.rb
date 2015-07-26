require 'rails_helper'

RSpec.describe "Dances", type: :request do
  describe "GET /dances" do
    it "works! (now write some real specs)" do
      get dances_path
      expect(response).to have_http_status(200)
    end
  end
end
