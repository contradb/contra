FactoryGirl.define do
  factory :tag do
    sequence(:name) {|n| "edgy#{n}" }

    trait :verified do
      name 'verified'
      glyphicon 'glyphicon-ok'
      on_verb 'have called'
      on_verb_3rd_person_singular 'has called'
      on_phrase 'this transcription'
      off_sentence 'no known calls of this transcription'
    end

    trait :broken do
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
