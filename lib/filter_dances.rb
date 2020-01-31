# coding: utf-8
require 'set'
require 'search_match'
require 'sort_parser'

module FilterDances
  def self.filter_dances(filter,
                         dialect:,
                         count: 10,
                         offset: 0,
                         sort_by: "")
    filter.is_a?(Array) or raise "filter must be an array, but got #{filter.inspect} of class #{filter.class}"
    query = Dance.includes(:choreographer, :user).references(:choreographer, :user).order(*SortParser.parse(sort_by))
    number_searched = 0
    number_matching = 0
    filter_results = []
    query.map do |dance|
      number_searched += 1
      mf = matching_figures(filter, dance)
      if mf
        number_matching += 1
        send_this_dance = offset < number_matching && number_matching <= offset + count
        if send_this_dance
          mf_html = matching_figures_html(mf, dance, dialect)
          filter_results << filter_result_to_json(dance, mf_html)
        end
      end
    end
    {
      numberSearched: number_searched,
      numberMatching: number_matching,
      dances: filter_results
    }
  end

  def self.matching_figures_html(matching_figures, dance, dialect)
    matching_indicies = SearchMatch.flatten_set_to_index_a(matching_figures)
    if matching_indicies.length === dance.figures.length
      'whole dance'
    else
      matching_indicies.map {|i| JSLibFigure.figure_to_html(dance.figures[i], dialect)}.join('<br>').html_safe
    end
  end

  def self.filter_result_to_json(dance, matching_figures_html)
    {
      "id" => dance.id,
      "title" => dance.title,
      "choreographer_id" => dance.choreographer_id,
      "choreographer_name" => dance.choreographer.name,
      "formation" => dance.start_type,
      "hook" => dance.hook,
      "user_id" => dance.user_id,
      "user_name" => dance.user.name,
      "created_at" => dance.created_at.as_json,
      "updated_at" => dance.updated_at.as_json,
      "publish" => dance_publish_cell(dance.publish),
      # TODO: render this client-side. Send JSON of matching figures:
      "matching_figures_html" => matching_figures_html
    }
  end

  # this code is duplicated in dance_helper, but I can't figure out how to cleanly import it.
  def self.dance_publish_cell(enum_value)
    case enum_value
    when 'off'
      'private'
    when 'sketchbook'
      'sketchbook'
    when 'all'
      'everywhere'
    else
      raise 'fell through enum case'
    end
  end

  # matching_figures and matching_figures_* functions return either nil (failure) or a set of SearchMatches
  #
  # The set may have zero elements, which means a successful match, but no specific index matches all criteria.
  # To see an example of that, think of the dance (and (figure 'chain') (figure 'right left through')), which can
  # match because it has a chain, and a right left through, but no figure satisfies both of those exactly.

  def self.matching_figures(filter, dance)
    operator = filter.first
    nm = case operator
         when '&'
           'figurewise_and'
         else
           operator.gsub(' ', '_')
         end
    fn = :"matching_figures_for_#{nm}"
    raise "#{operator.inspect} is not a valid operator in #{filter.inspect}" unless self.respond_to?(fn, true)
    matches = send(fn, filter, dance)
    # puts "matching_figures #{dance.title} #{filter.inspect} = #{matches.inspect}"
    matches
  end

  def self.matching_figures_for_figure(filter, dance)
    filter_move = filter[1]
    nfigures = dance.figures.length
    if '*' == filter_move              # wildcard
      nfigures > 0 ? all_figures_match(nfigures) : nil
    else
      formals = JSLibFigure.is_move?(filter_move) ? JSLibFigure.formal_parameters(filter_move) : []
      search_matches = Set[]
      dance.figures.each_with_index do |figure, figure_index|
        actuals = JSLibFigure.parameter_values(figure)
        filter_canonical = JSLibFigure.de_alias_move(filter_move)
        filter_is_alias = filter_canonical != filter_move
        param_filters = filter.drop(2)
        param_filters = JSLibFigure.alias_filter(filter_move) if filter_is_alias && param_filters.empty?
        it_matches = JSLibFigure.move(figure) == filter_canonical &&
                     param_filters.each_with_index.all? {|param_filter, i| param_passes_filter?(formals[i], actuals[i], param_filter)}
        search_matches << SearchMatch.new(figure_index, nfigures) if it_matches
      end
      search_matches.present? ? search_matches : nil
    end
  end

  def self.param_passes_filter?(formal_param, dance_param, param_filter)
    if JSLibFigure.parameter_uses_chooser(formal_param, JSLibFigure.chooser('chooser_text'))
      # substring search
      keywords = param_filter.split(' ')
      keywords.any? {|keyword| dance_param.include?(keyword)}
    elsif JSLibFigure.parameter_uses_chooser(formal_param, JSLibFigure.chooser('chooser_half_or_full'))
      param_filter == '*' || param_filter.to_f === dance_param.to_f
    elsif JSLibFigure.formal_param_is_dancers(formal_param)
      param_filter == '*' || JSLibFigure.dancers_category(dance_param) === param_filter
    elsif param_filter == '*' || param_filter.to_s === dance_param.to_s
      # DEFUALT CASE: asterisk always matches, or exact match
      true
    elsif JSLibFigure.parameter_uses_chooser(formal_param, JSLibFigure.chooser('chooser_hey_length'))
      # some easy hey length cases - half/full exact match - are already handled above.
      meet_times = JSLibFigure.hey_length_meet_times(dance_param)
      if dance_param.in?(%w(half full))
        false
      else
        param_filter === 'less than half' && meet_times <= 1 or
          param_filter === 'between half and full' && meet_times == 2
      end
    else
      false
    end
  end

  def self.matching_figures_for_formation(filter, dance)
    filter_formation = filter[1]
    if filter_formation == 'everything else'
      FILTER_FORMATION_TO_RE.values.none? {|re| re =~ dance.start_type} ? Set[] : nil
    else
      filter_re = FILTER_FORMATION_TO_RE[filter_formation]
      filter_re or raise "unrecognised formation filter #{filter_formation.inspect}"
      filter_re =~ dance.start_type ? Set[] : nil
    end
  end

  FILTER_FORMATION_TO_RE = {'improper' => /improper/i,
                            'Becket *' => /Becket/i,
                            'Becket cw' => /Becket(?!.*ccw).*$/i,
                            'Becket ccw' => /Becket ccw/i,
                            'proper' => /^proper/i}

  def self.matching_figures_for_progression(filter, dance)
    nfigures = dance.figures.length
    s = Set[]
    dance.figures.each_with_index {|f,i| s << SearchMatch.new(i, nfigures) if JSLibFigure.progression(f)}
    s.present? ? s : nil
  end

  def self.matching_figures_for_if(filter, dance)
    _op, if_, then_, else_ = filter
    if matching_figures(if_, dance)
      matching_figures(then_, dance)
    elsif else_
      matching_figures(else_, dance)
    else
      nil
    end
  end

  def self.matching_figures_for_no(filter, dance)
    subfilter = filter[1]
    if matching_figures(subfilter, dance)
      nil
    else
      all_figures_match(dance.figures.length)
    end
  end

  def self.matching_figures_for_all(filter, dance)
    subfilter = filter[1]
    matches = matching_figures(subfilter, dance)
    if dance.figures.length == 0
      Set[]
    elsif matches && dance.figures.length.times.all? {|i| matches.any? {|search_match| search_match.include?(i)}}
      matches
    else
      nil
    end
  end

  def self.matching_figures_for_or(filter, dance)
    subfilters = filter.drop(1)
    matches = Set[]
    subfilters.each do |subfilter|
      matches |= matching_figures(subfilter, dance) || Set[]
    end
    matches.present? ? matches : nil
  end

  def self.matching_figures_for_and(filter, dance)
    subfilters = filter.drop(1)
    if subfilters.empty?
      Set[] # should arguably return the infinitely large set of all searchmatches instead
    else
      matches = subfilters.map {|subfilter| matching_figures(subfilter, dance) or return nil}
      m = matches.first
      matches.drop(1).each {|x| m &= x} # naive intersection, treating SearchMatch(1,8) as not intersecting with SearchMatch(1,8, count: 2)
      m
    end
  end

  def self.matching_figures_for_figurewise_and(filter, dance)
    a = matching_figures_for_and(filter, dance)
    a.present? ? a : nil
  end

  # figurewise_not
  def self.matching_figures_for_not(filter, dance)
    subfilter = filter[1]
    matches = all_figures_match(dance.figures.length) - dice_search_matches(matching_figures(subfilter, dance) || Set[])
    matches.present? ? matches : nil
  end

  def self.matching_figures_for_then(filter, dance)
    going_concerns = all_empty_matches(dance.figures.length)
    subfilters = filter.drop(1)
    subfilters.each do |subfilter|
      m = matching_figures(subfilter, dance)
      m or return nil
      new_concerns = Set[]
      going_concerns.each do |search_match_head|
        m.each do |search_match_tail|
          new_concern = search_match_head.abut(search_match_tail)
          new_concerns << new_concern if new_concern
        end
      end
      going_concerns = new_concerns
      return nil unless going_concerns.present?
    end
    going_concerns
  end

  def self.matching_figures_for_choreographer(filter, dance)
    choreographer = filter[1].downcase
    dance.choreographer.name.downcase.include?(choreographer) ? Set[] : nil
  end

  COMPARISON_STRING_TO_RUBY_OP = {'≥' => :'>=',
                                  '≤' => :'<=',
                                  '≠' => :'!=',
                                  '=' => :'==',
                                  '>' => :'>',
                                  '<' => :'<'}.freeze

  def self.matching_figures_for_count(filter, dance)
    _filter, subfilter, comparison_str, number_string = filter
    m = matching_figures(subfilter, dance)
    m_count = m.nil? ? 0 : m.length
    comparison = COMPARISON_STRING_TO_RUBY_OP.fetch(comparison_str)
    number = number_string.to_i
    if m_count.public_send(comparison, number) # for example 'count >= 3'
      m || Set[]
    else
      nil
    end
  end

  def self.matching_figures_for_compare(filter, dance)
    _filter, left, comparison_str, right = filter
    l = eval_numeric_ex(left, dance)
    r = eval_numeric_ex(right, dance)
    comparison = COMPARISON_STRING_TO_RUBY_OP.fetch(comparison_str)
    l.public_send(comparison, r) ? Set[] : nil
  end

  def self.eval_numeric_ex(nex, dance)
    case nex.first
    when 'constant'
      Integer(nex.second)           # Hm, is THIS the place to parse this string?
    when 'tag'
      tag_id = Tag.where(name: nex.second).pluck(:id).first
      tag_id ? Dut.where(tag_id: tag_id, dance_id: dance.id).count : 0
    when 'count-matches'
      subfilter = nex.second
      matches = matching_figures(subfilter, dance)
      matches ? matches.length : 0
    else
      raise "I do not know how to evaluate #{nex.first} expressions."
    end
  end

  def self.all_empty_matches(nfigures)
    Set.new(nfigures.times.map{|i| SearchMatch.new(i, nfigures, count: 0)})
  end

  def self.all_figures_match(nfigures)
    Set.new(nfigures.times.map{|i| SearchMatch.new(i, nfigures)})
  end

  # given a set of search matches, return a set of new search matches with count: 1 search matches for every index anywhere in the set
  def self.dice_search_matches(set)
    Set.new(
      set.map {|search_match| search_match.map {|i| SearchMatch.new(i, search_match.nfigures)}}.flatten)
  end
end
