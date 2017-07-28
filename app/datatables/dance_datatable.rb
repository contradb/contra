class DanceDatatable < AjaxDatatablesRails::Base

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id: { source: "Dance.id" },
      title: { source: "Dance.title" },
      choreographer_name: { source: "Choreographer.name" }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        title: record.title,
        choreographer_name: record.choreographer.name
      }
    end
  end

  private

  def get_raw_records
    Dance.includes(:choreographer).references(:choreographer)
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
