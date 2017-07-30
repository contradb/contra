jQuery(document).ready(function() {
  $('#dances-table').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#dances-table').data('source'),
    "pagingType": "full_numbers",
    "dom": 'tf<"row"<"col-sm-6"i><"col-sm-6"l>><rp>',
    "order": [[ 3, "desc" ]],
    "columns": [
      {"data": "title"},
      {"data": "choreographer_name"},
      {"data": "user_name"},
      {"data": "updated_at"}
    ]
    // pagingType is optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  });
});
