class Idiom::Dancer < Idiom::Idiom
  def self.set_roles(user, ladle, ladles, gentlespoon, gentlespoons)
    {'ladle' => ladle,
     'ladles' => ladles,
     'first ladle' => "first #{ladle}",
     'second ladle' => "second #{ladle}",
     'gentlespoon' => gentlespoon,
     'gentlespoons' => gentlespoons,
     'first gentlespoon' => "first #{gentlespoon}",
     'second gentlespoon' => "second #{gentlespoon}"
    }.each do |term, substitution|
      idiom = user.idioms.find_or_initialize_by(user_id: user.id, type: self.name, term: term)
      idiom.update!(substitution: substitution)
    end
  end

  def self.clear_roles(user)
    user.idioms.where(term: ['ladle',
                             'ladles',
                             'first ladle',
                             'second ladle',
                             'gentlespoon',
                             'gentlespoons',
                             'first gentlespoon',
                             'second gentlespoon']).destroy_all
  end
end
