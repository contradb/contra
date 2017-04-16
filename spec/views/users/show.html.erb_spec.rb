# -*- coding: utf-8 -*-

require 'rails_helper'

RSpec.describe "users/show", type: :view do
  it "renders attributes" do
    user = FactoryGirl.build_stubbed(:user)
    assign(:user, user)
    assign(:dances, user.dances)
    assign(:programs, user.programs)
    render
    expect(rendered).to have_content(user.name)
    expect(rendered).to_not have_content('Administrator')
  end
  it "renders admin" do
    user = FactoryGirl.build_stubbed(:user, is_admin: true)
    assign(:user, user)
    assign(:dances, user.dances)
    assign(:programs, user.programs)
    render
    expect(rendered).to have_content(user.name)
    expect(rendered).to have_content('Administrator')
  end
end
