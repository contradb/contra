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
      on_verb: 'have called',
      on_verb_3rd_person_singular: 'has called',
      on_phrase: 'this transcription',
      off_sentence: 'no known calls of this transcription'}
     # ,
     # {name: 'please review', glyphicon: 'glyphicon-fire', bootstrap_color: 'danger',
     #  on_verb: 'have reported',
     #  on_verb_3rd_person_singular: 'has reported',
     #  on_phrase: 'this',
     #  off_sentence: 'no reports of issues'}
    ]
  end
end
