class CreateActivities < ActiveRecord::Migration[4.2]
  def change
    create_table :activities do |t|
      t.integer    :index,                                   null: false
      t.references :program, index: true, foreign_key: true, null: false
      t.references :dance,   index: true, foreign_key: true, null: true
      t.text       :text,                                    null: true
      t.timestamps                                           null: false
    end
  end
end
