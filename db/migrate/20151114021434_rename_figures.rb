class RenameFigures < ActiveRecord::Migration
  def change
    rename_column :dances, :figures, :figures_json
  end
end
