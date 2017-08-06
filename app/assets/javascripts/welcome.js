jQuery(document).ready(function() {
  var dataTable = 
        $('#dances-table').DataTable({
          "processing": true,
          "serverSide": true,
          "ajax": {
            url: $('#dances-table').data('source'),
            data: function(d) {
              d.includeMoves = $('#include-moves').val(); 
              d.excludeMoves = $('#exclude-moves').val();
            }
          },
          "pagingType": "full_numbers",
          "dom": 'ft<"row"<"col-sm-6 col-md-3"i><"col-sm-6 col-md-3"l>>pr',
          language: {
            searchPlaceholder: "search"
          },
          "order": [[ 3, "desc" ]],
          "columns": [
            {"data": "title"},
            {"data": "choreographer_name"},
            {"data": "user_name"},
            {"data": "updated_at"}
          ]
        });
  $('#include-moves').change(function () { dataTable.draw();});
  $('#exclude-moves').change(function () { dataTable.draw();});
});
