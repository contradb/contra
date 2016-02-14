class RewriteGypsyToGyre < ActiveRecord::Migration

  def contraFigureRewrite (key, from, to)
    Dance.all.each do |d|
      if d.figures.any? {|f| f[key] =~ from}
        f2 = d.figures.map {|f| f[key] =~ from ? f.merge({key => f[key].gsub(from, to)}) : f}
        d.figures_json = JSON.generate f2
        d.save
      end
    end
  end

  # no reason this code couldn't be reused in the future, 
  # if these constants are carefully updated. 
  Key = 'move'
  Bad  = 'gypsy'
  Good = 'gyre'
  BadRegEx  = /#{Bad}/
  GoodRegEx = /#{Good}/

  def up
    contraFigureRewrite(Key, BadRegEx, Good)
  end

  def down
    contraFigureRewrite(Key, GoodRegEx, Bad)
  end
end
