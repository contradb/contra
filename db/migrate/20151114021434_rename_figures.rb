class RenameFigures < ActiveRecord::Migration[4.2]
  def change
    rename_column :dances, :figures, :figures_json
  end
end
