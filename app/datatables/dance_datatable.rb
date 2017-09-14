class DanceDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :dance_path, :choreographer_path, :user_path

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      title: { source: "Dance.title" },
      choreographer_name: { source: "Choreographer.name" },
      user_name: { source: "User.name" },
      updated_at: { source: "Dance.updated_at", searchable: false, orderable: true }
    }
  end

  def data
    records.map do |dance|
      {
        title: link_to(dance.title, dance_path(dance)),
        choreographer_name: link_to(dance.choreographer.name, choreographer_path(dance.choreographer)),
        user_name: link_to(dance.user.name, user_path(dance.user)),
        updated_at: dance.updated_at.strftime('%Y-%m-%d')
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

  # These functions return either nil (failure) or an array of matching figure indicies.
  # 
  # The array may have zero elements, which means a successful match, but no specific index matches all criteria.
  # To see an example of that, think of the dance (and (figure 'chain') (figure 'right left through')), which can
  # match because it has a chain, and a right left through, but no figure satisfies both of those exactly. 
  #
  # The array must always be sorted

  def self.matching_figures(filter, dance)
    operator = filter.first
    fn = :"matching_figures_for_#{operator}"
    # binding.pry unless self.respond_to?(fn)
    raise "#{operator.inspect} is not a valid operator in #{filter.inspect}" unless self.respond_to?(fn)
    matches = self.send(fn, filter, dance)
    # puts "matching_figures #{dance.title} #{filter.inspect} = #{matches.inspect}"
    matches
  end

  def self.matching_figures_for_figure(filter, dance)
    move = filter[1]
    indicies = dance.figures.each_with_index.map {|figure, index| figure['move'] == move ? index : nil}
    indicies.any? ? indicies.compact : nil
  end

  def self.matching_figures_for_none(filter, dance)
    subfilter = filter[1]
    if matching_figures(subfilter, dance).present? # Hmmm... XXX worry
      nil
    else
      all_figure_indicies(dance)
    end
  end

  def self.matching_figures_for_all(filter, dance)
    subfilter = filter[1]
    all = all_figure_indicies(dance)
    if matching_figures(subfilter, dance) == all
      all
    else
      nil
    end
  end

  def self.matching_figures_for_or(filter, dance)
    subfilters = filter.drop(1)
    figures_length = dance.figures.length
    matches = []
    subfilters.each do |subfilter|
      matches |= matching_figures(subfilter, dance) || []
      return matches.sort if matches.length == figures_length
    end
    matches.present? ? matches.sort : nil
  end

  def self.matching_figures_for_and(filter, dance)
    subfilters = filter.drop(1)
    matching_figs = subfilters.map {|subfilter| matching_figures(subfilter, dance)}
    if matching_figs.all?
      matches = all_figure_indicies(dance)
      matching_figs.each {|x| matches &= x}
      matches
    else
      nil
    end
  end

  def self.matching_figures_for_not(filter, dance)
    subfilter = filter[1]
    figures = all_figure_indicies(dance) - (matching_figures(subfilter, dance) || [])
    figures.present? ? figures.sort : nil
  end

  def self.matching_figures_for_follows(filter, dance)
    subfilters = filter.drop(1)
    figures_count = dance.figures.count
    current_figures = all_figure_indicies(dance)
    subfilters.each do |subfilter|
      current_figures = shift_figure_indicies(current_figures, figures_count) & (matching_figures(subfilter, dance) || [])
      return nil if current_figures.empty?
    end
    current_figures
  end

  def self.shift_figure_indicies(figure_indicies, figures_count)
    x = figure_indicies.map {|f| f+1}
    if figure_indicies.last + 1 == figures_count
      x.pop
      x.unshift(0)
    end
    x
  end

  def self.all_figure_indicies(dance)
    [*0...dance.figures.count]
  end

  # def self.select_dance_for_figure?(filter, dance)
  #   move = filter[1]
  #   dance.figures.any? {|figure| figure['move'] == move}
  # end

  # def self.select_dance_for_and?(filter, dance)
  #   subfilters = filter.drop(1)
  #   subfilters.all? {|subfilter| select_dance?(subfilter, dance)}
  # end

  # def self.select_dance_for_or?(filter, dance)
  #   subfilters = filter.drop(1)
  #   subfilters.any? {|subfilter| select_dance?(subfilter, dance)}
  # end

  # def self.select_dance_for_not?(filter, dance)
  #   subfilter = filter[1]
  #   not select_dance?(subfilter, dance)
  # end

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
