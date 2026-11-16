require 'rails_helper'

RSpec.describe "about/index.html.erb", type: :view do
  it 'displays license, copyright, and github link' do
    render
    expect(rendered).to have_link 'AGPL3 license', href: 'http://www.gnu.org/licenses/agpl-3.0.en.html'
    years = [*2015..2022, *2026..Time.now.year]
    expect(rendered).to match /ContraDB copyright #{years.join ','} by David Morse/
    expect(rendered).to have_link 'source code', href: 'http://github.com/contradb/contra'
  end
end
