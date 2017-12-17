class AddPreambleAndHookToDances < ActiveRecord::Migration[5.0]
  def change
    add_column :dances, :preamble, :text, default: '', null: false
    add_column :dances, :hook, :text, default: '', null: false
  end
end
