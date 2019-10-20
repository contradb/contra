class RenameDancePublishColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column(:dances, :publish, :boolean_publish)
  end
end
