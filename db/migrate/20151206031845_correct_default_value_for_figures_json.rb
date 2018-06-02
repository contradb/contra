class CorrectDefaultValueForFiguresJson < ActiveRecord::Migration[4.2]
  def change
    change_column :dances, :figures_json, :text, :null => false, :default => '[]'
  end
end
