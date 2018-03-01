# coding: utf-8

require 'rails_helper'


describe 'Help page' do
  it 'works' do
    visit(help_path)
    expect(page).to have_content('why are we here?')
    expect(page).to have_content('how do I enter a dance?')
    expect(page).to have_content('how do I search for dances?')
  end
end
