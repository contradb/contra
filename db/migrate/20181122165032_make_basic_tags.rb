class MakeBasicTags < ActiveRecord::Migration[5.1]

  def up
    tag_attributes.map {|attrs| Tag.create!(attrs)}
  end

  def down
    tag_attributes.map {|attrs| Tag.find_by(name: attrs.fetch(:name))&.destroy!}
  end

  private
  def tag_attributes
    [{name: 'verified', glyphicon: 'glyphicon-ok'},
     {name: 'broken', glyphicon: 'glyphicon-fire', color: 'red'}]
  end
end
