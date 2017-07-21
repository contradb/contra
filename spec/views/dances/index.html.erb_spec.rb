require 'rails_helper'

RSpec.describe "dances/index", type: :view do
  it "renders a list of dances" do
    @dances =
      [build_stubbed(:dance, title: "Simplicity Swing1", start_type: "Whatever Crazy Formation"),
       build_stubbed(:dance, title: "Simplicity Swing2"),
       build_stubbed(:dance, title: "Simplicity Swing3")]
    render
    expect(rendered).to match(/Simplicity Swing1/)
    expect(rendered).to match(/Simplicity Swing2/)
    expect(rendered).to match(/Simplicity Swing3/)
    expect(rendered).to match(/Whatever Crazy Formation/)
  end

  it "renders stompiness" do
    @dances = [build_stubbed(:dance, title: "Somewhat Stompy")]
    expect(@dances.first).to receive(:stompiness).and_return(0.4)
    render
    expect(rendered).to match('40%')
  end
end
