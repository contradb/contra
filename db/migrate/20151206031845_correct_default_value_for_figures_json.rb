class CorrectDefaultValueForFiguresJson < ActiveRecord::Migration
  def change
    change_column :dances, :figures_json, :text, :null => false, :default => '[]'
  end
end
