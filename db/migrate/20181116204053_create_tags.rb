class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, unique: true
      t.string :glyphicon, null: false, default: 'glyphicon-tag'
      t.string :bootstrap_color, null: true
      t.string :on_verb
      t.string :on_verb_3rd_person_singular
      t.string :on_phrase
      t.string :off_sentence
      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end
