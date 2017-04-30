
require 'rails_helper'

describe 'figures index' do
  it 'has links to sluggified figures' do
    visit figures_path
    expect(page).to have_link('swing', href: figure_path('swing'))
    expect(page).to have_link('do si do', figure_path('do-si-do'))
    expect(page).to have_link("Rory O'Moore", figure_path('rory-omoore'))
  end
end
