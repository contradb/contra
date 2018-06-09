require 'json'

class MergeFigures < ActiveRecord::Migration[4.2]

  # wat? http://guides.rubyonrails.org/v3.2.21/migrations.html#using-models-in-your-migrations
  class Dance < ActiveRecord::Base
  end

  def up
    add_column :dances, :figures, :text, :null => false, :default => '{}'

    Dance.reset_column_information 

    Dance.all.each do |d|
      d.figures = figure_packer(d.figure1,d.figure2,d.figure3,d.figure4,d.figure5,d.figure6,d.figure7,d.figure8)
      d.save
      if verbose_migration_mode then
        puts "MIGRATION"
        puts d.inspect
        (1..8).each do |i|
          puts "figure"+i.to_s + ":   " + d["figure"+i.to_s]
        end
        puts "figures:   "+d.figures
        puts "\n\n"
      end
    end
    remove_column :dances, :figure1
    remove_column :dances, :figure2
    remove_column :dances, :figure3
    remove_column :dances, :figure4
    remove_column :dances, :figure5
    remove_column :dances, :figure6
    remove_column :dances, :figure7
    remove_column :dances, :figure8
  end

  def down
    add_column :dances, :figure1, :text, :null => false, :default => ''
    add_column :dances, :figure2, :text, :null => false, :default => ''
    add_column :dances, :figure3, :text, :null => false, :default => ''
    add_column :dances, :figure4, :text, :null => false, :default => ''
    add_column :dances, :figure5, :text, :null => false, :default => ''
    add_column :dances, :figure6, :text, :null => false, :default => ''
    add_column :dances, :figure7, :text, :null => false, :default => ''
    add_column :dances, :figure8, :text, :null => false, :default => ''

    Dance.reset_column_information 
    Dance.all.each do |d|
      o = figure_unpacker(d.figures)
      d.update_attributes o
      d.save

      if verbose_migration_mode then
        puts "MIGRATION"
        puts d.inspect
        puts "WITH figures (soon to be figures_json) OF"
        puts d.figures
        puts "CALLED update_attributes WITH "
        puts o.inspect
        puts "\n\n"
      end

    end

    remove_column :dances, :figures
  end

  def verbose_migration_mode
    true
  end

  # return a JSON string to store in .figures
  def figure_packer(*args)
    '[' + args.join(', ') + ']'
  end

  # return an object with properties .figure1 .. .figure8
  def figure_unpacker(figures_str)
    f = JSON.parse figures_str
    fail unless f.kind_of?(Array)
    o = {}
    f.each_with_index{|v,i| 
      if i<8
      then o["figure"+(i+1).to_s] = JSON.generate v
      else fail # dance with more than 8 figures can't be migrated without loss
      end
    }
    o
  end
end
