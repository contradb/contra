require "rails_helper"

RSpec.describe ChoreographersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/choreographers").to route_to("choreographers#index")
    end

    it "routes to #new" do
      expect(:get => "/choreographers/new").to route_to("choreographers#new")
    end

    it "routes to #show" do
      expect(:get => "/choreographers/1").to route_to("choreographers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/choreographers/1/edit").to route_to("choreographers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/choreographers").to route_to("choreographers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/choreographers/1").to route_to("choreographers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/choreographers/1").to route_to("choreographers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/choreographers/1").to route_to("choreographers#destroy", :id => "1")
    end

  end
end
