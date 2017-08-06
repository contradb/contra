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
    dances = Dance.readable_by(user).to_a.
             reject do |dance|
               dance_moves = dance.figures.map {|figure| figure['move']}
               exclude_moves.any? {|exclude_move| exclude_move.in? dance_moves}
             end. 
             select do |dance|
               dance_moves = dance.figures.map {|figure| figure['move']}
               include_moves.all? {|include_move| include_move.in? dance_moves}
             end
    Dance.where(id: dances.map(&:id)).includes(:choreographer, :user).references(:choreographer, :user)
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

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
