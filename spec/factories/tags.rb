FactoryGirl.define do
  factory :tag do
    sequence(:name) {|n| "edgy#{n}" }

    # mirrored in production
    trait :verified do
      name 'verified'
      glyphicon 'glyphicon-ok'
      on_verb 'have called'
      on_verb_3rd_person_singular 'has called'
      on_phrase 'this transcription'
      off_sentence 'no known calls of this transcription'
    end

    # mirrored in production
    trait :experimental do
      name 'experimental'
      glyphicon 'glyphicon-warning-sign'
      on_phrase 'choreography in progress'
      off_sentence 'choreography is finalized'
    end
    # Tag.create!(name: 'experimental', glyphicon: 'glyphicon-warning-sign', bootstrap_color: 'danger', on_phrase: 'choreography in progress', off_sentence: 'choreography is finalized')


    # not currently mirrored in production
    # Tag.create!(name: 'please review', glyphicon: 'glyphicon-fire', bootstrap_color: 'danger', on_verb: 'have reported', on_verb_3rd_person_singular: 'has reported', on_phrase: 'this', off_sentence: 'no reports of issues')
    trait :please_review do
      name 'please review'
      glyphicon 'glyphicon-fire'
      bootstrap_color 'danger'
      on_verb 'have reported'
      on_verb_3rd_person_singular 'has reported'
      on_phrase 'this'
      off_sentence 'no reports of issues'
    end
  end
end
