class MakeBasicTags < ActiveRecord::Migration[5.1]

  def up
    tag_attributes.map {|attrs| Tag.create!(attrs)}
  end

  def down
    tag_attributes.map {|attrs| Tag.find_by(name: attrs.fetch(:name))&.destroy!}
  end

  private
  def tag_attributes
    [{name: 'verified', glyphicon: 'glyphicon-ok',
      on_phrase: 'have called this transcription', off_sentence: 'no known calls of this transcription'},
     {name: 'broken', glyphicon: 'glyphicon-fire', bootstrap_color: 'danger',
      on_phrase: 'have reported this', off_sentence: 'no reports of issues'}]
  end
end
