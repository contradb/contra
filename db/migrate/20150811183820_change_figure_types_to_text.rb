class ChangeFigureTypesToText < ActiveRecord::Migration
  def change
    # This is likely a one-way trip, see:
    # http://blog.nerdery.com/2013/12/ruby-rails-migrating-string-text-back/
    change_column :dances, :figure1, :text
    change_column :dances, :figure2, :text
    change_column :dances, :figure3, :text
    change_column :dances, :figure4, :text
    change_column :dances, :figure5, :text
    change_column :dances, :figure6, :text
    change_column :dances, :figure7, :text
    change_column :dances, :figure8, :text
  end
end
