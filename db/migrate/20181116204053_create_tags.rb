class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, unique: true
      t.string :glyphicon, null: false, default: 'glyphicon-tag'
      t.string :bootstrap_color, null: true
      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end
