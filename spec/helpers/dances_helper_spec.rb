# coding: utf-8
require 'rails_helper'

RSpec.describe DancesHelper, type: :helper do

  figure_txt_for = -> move, *parameter_values {
    JSLibFigure.html({'move' => move, 'parameter_values' => parameter_values})
  }

  def whitespice(x) 
    case x
    when Regexp; x
    when String;
      quote = Regexp.escape(x).to_s
      /\A\s*#{quote.gsub('\ ','\s+')}\s*\z/
    else raise 'unexpected type in whitespice'
    end
  end

  [['partners balance & swing', 'balance and swing', 'partners',true, 16],
   ['partners balance & swing','balance and swing','partners',true,16],
   ['neighbors balance & swing', 'swing', 'neighbors', true, 16],
   ['neighbors swing', 'swing', 'neighbors', false, 8],
   ['partners long swing','long swing', 'partners', false, 16],
   ['partners swing for 16','swing', 'partners', false, 16],
   ['gentlespoons allemande right 1½', 'allemande', 'gentlespoons', true, 540, 8],
   ['gentlespoons allemande right twice for 10', 'allemande', 'gentlespoons', true, 720, 10],
   ['ladles allemande left 1½ around while the gentlespoons orbit clockwise ½ around', 'allemande orbit','ladles',false,540,180,8],
   ['ones balance', 'balance', 'ones', 4],
   ['ones balance for 8', 'balance', 'ones', 8],
   ['balance the ring for 6', 'balance the ring', 6],
   ['ladies chain', 'chain', 'ladies', 8],
   ['circle left 4 places','circle',true,360,8],
   ['circle right 4 places','circle',false,360,8],
   ['circle left 3 places', 'circle', true, 270, 8],
   ['put your right hand in', 'custom', 'put your right hand in', 8],
   ['put your right hand in for 16', 'custom', 'put your right hand in', 16],
   ['gentlespoons balance & twerk', 'custom yucky', 'gentlespoons', true, 'twerk', 8],
   ['half hey, ladles lead', 'half hey', 'ladles', 8],
   ['hey, gentlespoons lead', 'hey', 'gentlespoons', 16],
   ['long lines', 'long lines', 8],
   ['long lines forward only for 3', 'long lines forward only', 3],
   ['balance & petronella', 'petronella', true, 8],
   # ['petronella', 'petronella', false, 8], ambiguous
   ['balance & petronella', 'petronella', true, 8],
   ['progress to new neighbors', 'progress', 0],
   ['pull by up & down the set', 'pull by', false, 'along', true, 2],
   ['pull by left up & down the set', 'pull by', false, 'along', false, 2],
   ['pull by across the set', 'pull by', false, 'across', true, 2],
   ['pull by left across the set', 'pull by', false, 'across', false, 2],
   ['balance & pull by up & down the set', 'pull by', true, 'along', true, 8],
   ['balance & pull by left up & down the set for 6', 'pull by', true, 'along', false, 6],
   ['balance & pull by across the set', 'pull by', true, 'across', true, 8],
   ['balance & pull by left across the set for 6', 'pull by', true, 'across', false, 6],
   ['neighbors promenade across passing on the left', 'promenade across', 'neighbors', true, 8],
   ['neighbors promenade across', 'promenade across', 'neighbors', false, 8],
   ['right left through', 'right left through', 8],
   ['slide left along set to new neighbors', 'slide along set', true, 2],
   ['star promenade left ½', 'star promenade', false, 180, 4], # prefer: "scoop up partner for star promenade"
   ['butterfly whirl', 'butterfly whirl', 4],
   ['butterfly whirl for 8', 'butterfly whirl', 8],
   ['down the hall', 'down the hall', 'forward', 8],
   ['down the hall backward', 'down the hall', 'backward', 8],
   ['up the hall', 'up the hall', 'forward', 8],
   ['up the hall forward and backward', 'up the hall', 'forward and backward', 8],
   ['mad robin - gentlespoons forward', 'mad robin', 'gentlespoons', 360, 8],
   ['mad robin twice around - ladles forward', 'mad robin', 'ladles', 720, 8],
   ['hands across star left 4 places','star', false, false, 360, 8],
   ['star left 4 places',             'star', false, true, 360, 8],
   ['partners balance & swat the flea', 'swat the flea', 'partners',  true,  false, 8],
   ['ocean wave', 'ocean wave', 4],
   ['gentlespoons roll away neighbor with a half sashay', 'roll away', 'gentlespoons', 'neighbor', true, 4],
   ['ladles roll away partner for 2', 'roll away', 'ladles', 'partner', false, 2],
   ["balance & Rory O'Moore right", "Rory O'Moore", false, true, 8],
   ['pass through up & down the set for 4', 'pass through', 'along', true, 4],
   ['pass through up & down the set', 'pass through', 'along', true, 2],
   ['pass through left shoulder across the set', 'pass through', 'across', false, 2],
   # below here has issues requiring implementation changes, I think -dm 08-16-2016
   ['gentlespoons see saw once', 'see saw', 'gentlespoons', false, 360, 8],
   ['petronella', 'petronella', false, 4],
   ['long lines forward only', 'long lines forward only', 4],
   ['balance the ring', 'balance the ring', 4],
   ['balance the ring for 8', 'balance the ring', 8], # debatable
   ['ladles chain', 'chain', 'ladles', 8],
   ['right left through', 'right left through', 8],
   ['partners balance & box the gnat',  'box the gnat',  'partners',  true,  true,  8],
   ['ladles do si do once', 'do si do', 'ladles', true, 360, 8],
   ['shadows gyre 1½', 'gyre', 'shadows', true, 540, 8],
   ['ones gyre left shoulder 1½', 'gyre', 'ones', false, 540, 8],
   ['neighbors box the gnat', 'box the gnat',  'neighbors', false, true,  4]
  ].each do |arr|
    render, move, *pvalues = arr
    it "renders #{move} as '#{render}'" do
      expect(figure_txt_for.call(move,*pvalues)).to match(whitespice(render))
    end
  end
end

