# coding: utf-8
require 'spec_helper'

describe "copyright file" do
  it "copyrights the right years" do
    years = [*2015..2022, *2026..Date.today.year]
    expect(open('COPYRIGHT').read).to include("Copyright #{years.join(',')} David Morse")
  end
end
