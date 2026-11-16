# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Safe to run more than once: each record is only created if it's missing.

# Choreographer#reattribute_dances_to_unknown assumes this is choreographer id 1,
# so it needs to be created first on an empty database.
Choreographer.find_or_create_by!(name: 'unknown')

# Mirrors the only tag in production (and the :verified trait in spec/factories/tags.rb).
# The search filters in app/javascript/ez-query-helpers.ts look it up by name.
Tag.find_or_create_by!(name: 'verified') do |tag|
  tag.glyphicon = 'glyphicon-ok'
  tag.on_verb = 'have called'
  tag.on_verb_3rd_person_singular = 'has called'
  tag.on_phrase = 'this transcription'
  tag.off_sentence = 'no known calls of this transcription'
end
