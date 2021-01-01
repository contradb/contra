# coding: utf-8
require 'spec_helper'

describe "copyright file" do
  it "copyrights the right years" do
    expect(open('COPYRIGHT').read).to include("Copyright #{(2015..Date.today.year).to_a.join(',')} David Morse")
  end
end
