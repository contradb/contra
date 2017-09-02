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
    puts "WACKY JSON "+ wacky_json.inspect
    filter = DanceDatatable.hash_to_array (wacky_json)
    filter = ['figure', 'chain']
    dances = Dance.readable_by(user).to_a
    dances = DanceDatatable.filter_dances(dances, filter)

    Dance.where(id: dances.map(&:id)).includes(:choreographer, :user).references(:choreographer, :user)
    # dances = Dance.readable_by(user).to_a.
    #          reject do |dance|
    #            dance_moves = dance.figures.map {|figure| figure['move']}
    #            exclude_moves.any? {|exclude_move| exclude_move.in? dance_moves}
    #          end. 
    #          select do |dance|
    #            dance_moves = dance.figures.map {|figure| figure['move']}
    #            include_moves.all? {|include_move| include_move.in? dance_moves}
    #          end
    # Dance.where(id: dances.map(&:id)).includes(:choreographer, :user).references(:choreographer, :user)
  end

  def user
    @user ||= options[:user]
  end

  def include_moves
    @include_moves ||= options[:include_moves]
  end

  def exclude_moves
    @exclude_moves ||= options[:exclude_moves]
  end

  def wacky_json
    @wacky_json ||= options[:wacky_json]
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
    dances.select {|dance| select_dance?(filter, dance)}
  end

  # FILTER_OPERATORS = %w[figure and or not follows]
  
  def self.select_dance?(filter, dance)
    operator = filter.first
    self.send(:"select_dance_for_#{operator}?", filter, dance)
  end

  def self.select_dance_for_figure?(filter, dance)
    move = filter[1]
    dance.figures.any? {|figure| figure['move'] == move}
  end

  def self.select_dance_for_and?(filter, dance)
    subfilters = filter.drop(1)
    subfilters.all? {|subfilter| select_dance?(subfilter, dance)}
  end

  def self.select_dance_for_or?(filter, dance)
    subfilters = filter.drop(1)
    subfilters.any? {|subfilter| select_dance?(subfilter, dance)}
  end

  def self.select_dance_for_not?(filter, dance)
    subfilter = filter[1]
    not select_dance?(subfilter, dance)
  end

  def self.hash_to_array(h)
    if !(h.instance_of?(Hash) || h.instance_of?(ActionController::Parameters))
      h
    elsif !h['faux_array']
      h
    else
      i = 0
      arr = []
      while h.key?(i)
        arr << hash_to_array(h[i])
        i += 1
      end
      arr
    end
  end
end
