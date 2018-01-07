
require 'rails_helper'

describe 'figures index' do
  it 'has links to sluggified figures' do
    visit figures_path
    expect(page).to have_title('Figure | Contra')
    expect(page).to have_link('swing', href: figure_path('swing'))
    expect(page).to have_link('do si do', href: figure_path('do-si-do'))
    expect(page).to have_link("Rory O'Moore", href: figure_path('rory-omoore'))
  end

  it 'is preference aware' do
    JSLibFigure.with_prefs(JSLibFigure.test_prefs) do
      visit figures_path
      expect(page).to have_link('swing', href: figure_path('swing'))
      expect(page).to have_link('almond', href: figure_path('allemande'))
      expect(page).to have_link('do si do left shoulder', href: figure_path('see saw'))
    end
  end
end
