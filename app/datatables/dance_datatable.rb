require 'set'
require 'search_match'

class DanceDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :dance_path, :choreographer_path, :user_path

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      title: { source: "Dance.title" },
      choreographer_name: { source: "Choreographer.name" },
      formation: { source: "Dance.start_type", searchable: false},
      hook: { source: "Dance.hook", searchable: false},
      user_name: { source: "User.name" },
      created_at: { source: "Dance.created_at", searchable: false, orderable: true },
      updated_at: { source: "Dance.updated_at", searchable: false, orderable: true },
      published: { source: "Dance.publish", searchable: false, orderable: true }
    }
  end

  def data
    records.map do |dance|
      {
        title: link_to(dance.title, dance_path(dance)),
        choreographer_name: link_to(dance.choreographer.name, choreographer_path(dance.choreographer)),
        formation: dance.start_type,
        hook: JSLibFigure.string_in_dialect(dance.hook, dialect),
        user_name: link_to(dance.user.name, user_path(dance.user)),
        created_at: dance.created_at.strftime('%Y-%m-%d'),
        updated_at: dance.updated_at.strftime('%Y-%m-%d'),
        published: dance.publish ? 'Published' : nil
      }
    end
  end

  private

  def get_raw_records
    filter = DanceDatatable.hash_to_array(figure_query)
    dances = Dance.readable_by(user).to_a
    dances = DanceDatatable.filter_dances(dances, filter)
    Dance.where(id: dances.map(&:id)).includes(:choreographer, :user).references(:choreographer, :user)
  end

  def user
    @user ||= options[:user]
  end

  def figure_query
    @figure_query ||= options[:figure_query]
  end

  def dialect
    @dialect ||= options[:dialect]
  end

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary


  private

  def self.filter_dances(dances, filter)
    raise "filter must be an array, but got #{filter.inspect} of class #{filter.class}" unless filter.is_a? Array
    dances.select {|dance| matching_figures?(filter, dance)}
  end

  def self.matching_figures?(filter, dance)
    matching_figures(filter, dance) != nil
  end

  # matching_figures and matching_figures_* functions return either nil (failure) or a set of SearchMatches
  #
  # The set may have zero elements, which means a successful match, but no specific index matches all criteria.
  # To see an example of that, think of the dance (and (figure 'chain') (figure 'right left through')), which can
  # match because it has a chain, and a right left through, but no figure satisfies both of those exactly.

  def self.matching_figures(filter, dance)
    operator = filter.first
    nm = case operator
         when '~'
           'figurewise_not'
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
    if JSLibFigure.parameter_uses_chooser(formal_param, 'chooser_text')
      # substring search
      keywords = param_filter.split(' ')
      keywords.any? {|keyword| dance_param.include?(keyword)}
    elsif JSLibFigure.parameter_uses_chooser(formal_param, 'chooser_half_or_full')
      param_filter === '*' || param_filter.to_f === dance_param.to_f
    elsif JSLibFigure.formal_param_is_dancers(formal_param)
      param_filter === '*' || JSLibFigure.dancers_category(dance_param) === param_filter
    else
      # asterisk always matches, or exact match
      param_filter === '*' || param_filter.to_s === dance_param.to_s
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
                            'proper' => /^proper/i};

  def self.matching_figures_for_progression(filter, dance)
    nfigures = dance.figures.length
    s = Set[]
    dance.figures.each_with_index {|f,i| s << SearchMatch.new(i, nfigures) if f['progression']} # todo: make figure accessor in jslibfigure
    s.present? ? s : nil
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

  # ~ is mainly useful when paired with then
  def self.matching_figures_for_figurewise_not(filter, dance)
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

  def self.hash_to_array(h)
    h = h.to_h if h.instance_of?(ActionController::Parameters)
    if !(h.instance_of?(Hash) || h.instance_of?(ActiveSupport::HashWithIndifferentAccess))
      h
    elsif !h['faux_array']
      h
    else
      i = 0
      arr = []
      while h.key?(i.to_s)
        arr << hash_to_array(h[i.to_s])
        i += 1
      end
      arr
    end
  end
end
