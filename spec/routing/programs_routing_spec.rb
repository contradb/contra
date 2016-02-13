require "rails_helper"

RSpec.describe ProgramsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/programs").to route_to("programs#index")
    end

    it "routes to #new" do
      expect(:get => "/programs/new").to route_to("programs#new")
    end

    it "routes to #show" do
      expect(:get => "/programs/1").to route_to("programs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/programs/1/edit").to route_to("programs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/programs").to route_to("programs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/programs/1").to route_to("programs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/programs/1").to route_to("programs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/programs/1").to route_to("programs#destroy", :id => "1")
    end

  end
end
