require "rails_helper"

RSpec.describe DancesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dances").to route_to("dances#index")
    end

    it "routes to #new" do
      expect(:get => "/dances/new").to route_to("dances#new")
    end

    it "routes to #show" do
      expect(:get => "/dances/1").to route_to("dances#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/dances/1/edit").to route_to("dances#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/dances").to route_to("dances#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/dances/1").to route_to("dances#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/dances/1").to route_to("dances#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/dances/1").to route_to("dances#destroy", :id => "1")
    end

  end
end
