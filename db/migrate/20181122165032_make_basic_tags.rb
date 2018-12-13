class MakeBasicTags < ActiveRecord::Migration[5.1]

  def up
    basic_tag_names.map {|name| Tag.create!(name: name)}
  end

  def down
    basic_tag_names.map {|name| Tag.find_by(name: name)&.destroy!}
  end

  private
  def basic_tag_names
    ['verified', 'broken']
  end
end
