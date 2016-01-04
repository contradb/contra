require 'rails_helper'

RSpec.describe "dances/index", type: :view do
  before(:each) do
    @dances =
      [build_stubbed(:dance, title: "Simplicity Swing1", start_type: "Whatever Crazy Formation"),
       build_stubbed(:dance, title: "Simplicity Swing2"),
       build_stubbed(:dance, title: "Simplicity Swing3")]
    @inviso_dance = build_stubbed(:dance, title: "not in the database")
  end

  it "renders a list of dances" do
    render
    expect(rendered).to match(/Simplicity Swing1/)
    expect(rendered).to match(/Simplicity Swing2/)
    expect(rendered).to match(/Simplicity Swing3/)
    expect(rendered).to match(/Whatever Crazy Formation/)
    expect(rendered).to_not match(/not in the database/)
  end
end
