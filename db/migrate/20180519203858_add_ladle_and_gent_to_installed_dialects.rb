class AddLadleAndGentToInstalledDialects < ActiveRecord::Migration[5.1]
  def down
    puts "Start with #{Idiom::Dancer.all.count} dancer idioms"
    Idiom::Dancer.where(term: "ladle").map(&:destroy!)
    Idiom::Dancer.where(term: "gentlespoon").map(&:destroy!)
    puts "End with #{Idiom::Dancer.all.count} dancer idioms"
  end

  def up
    puts "Start with #{Idiom::Dancer.all.count} dancer idioms"
    Idiom::Dancer.where(term: "ladles").each {|idiom| copy_it(idiom, 'ladle', singularize(idiom.substitution))}
    Idiom::Dancer.where(term: "gentlespoons").each {|idiom| copy_it(idiom, 'gentlespoon', singularize(idiom.substitution))}
    puts "End with #{Idiom::Dancer.all.count} dancer idioms"
  end

  def copy_it(idiom, new_term, new_substitution)
    attrs = idiom.attributes.except(*%w(id created_at updated_at)).merge(term: new_term, substitution: new_substitution)
    puts attrs.inspect
    idiom = Idiom::Dancer.create(attrs)
    puts idiom.to_s
  end

  def singularize(substitution)
    {'gents' => 'gent',
     'ladies' => 'lady',
     'larks' => 'lark',
     'ravens' => 'raven',
     'leads' => 'lead',
     'follows' => 'follow',
     'men' => 'man',
     'women' => 'women'
    }.fetch(substitution)
  end
end
