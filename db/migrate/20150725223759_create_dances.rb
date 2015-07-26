class CreateDances < ActiveRecord::Migration
  def change
    create_table :dances do |t|
      t.belongs_to :user
      t.string :title
      t.belongs_to :choreographer
      t.string :start_type 
      t.string :figure1
      t.string :figure2
      t.string :figure3
      t.string :figure4
      t.string :figure5
      t.string :figure6
      t.string :figure7
      t.string :figure8
      t.text :notes

      t.timestamps null: false
    end
  end
end
