class CreatePreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :preferences do |t|
      t.string :type, null: false
      t.string :term, null: false
      t.string :substitution, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
