  function installEventHandlers(selector) {
    selector.find('.figure-filter-op').change(filterOpChanged);
    selector.find('.figure-filter-add').click(filterAddSubfilter);
  }
  
  var filterHtml = "\
    <div class='figure-filter'>\
      <select class='figure-filter-op'>\
        <option value='figure' selected>figure</option>\
        <option value='and'>and</option> \
        <option value='or'>or</option>\
        <option value='follows'>follows</option>\
        <option value='none'>none</option>\
        <option value='all'>all</option>\
        <option value='not'>not</option>\
      </select>\
      <select class='figure-move'>\
        <option value='swing'>swing</option>\
        <option value='chain' selected>chain</option>\
        <option value='right left through'>right left through</option>\
      </select>\
    </div>\
"

  function filterOpChanged(e) {
    var opSelect = $(e.target);
    var filter = opSelect.closest('.figure-filter');
    var op = opSelect.val();
    console.log('op = '+op);
    // TODO right-size subfilters
    if (op === 'figure') {
      // TODO 
    } else {
      $(filter).remove('.figure-move'); // if we were a figure filter
      // TODO add
    }
    updateQuery();
  }

  function filterAddSubfilter(e) {
    var newFilter = $(filterHtml);
    newFilter.insertBefore(this);
    installEventHandlers(newFilter);
    updateQuery();
  }

  function filterX(e) {         // delete filter
    // if (it makes sense)
    // remove the filter
    updateQuery();
  }

  var updateQuery;              // defined below...

  function buildFilter(figure_filter) {
    figure_filter = $(figure_filter);
    var op = figure_filter.children('.figure-filter-op').val();
    console.log('op = '+op);
    if (op === 'figure') {
       return [op, figure_filter.children('.figure-move').val()];
    } else {
      var kids = figure_filter.children('.figure-filter').get();
      if (!Array.prototype.map) { throw "I was expecting Array.map to be defined"; }
      var filter = kids.map(buildFilter);
      filter.unshift(op);
      console.log(filter);
      return filter;
    }
  }



jQuery(document).ready(function() {


  installEventHandlers($('#figure-filter-root'));


  // ================================================================

  updateQuery = function() {
    $('#query-buffer').val(JSON.stringify(buildFilter($('#figure-filter-root'))));
    if (dataTable) {
      dataTable.draw(); 
    }
  }
  updateQuery();

  if (!Array.isArray) {
    Array.isArray = function(arg) {
      return Object.prototype.toString.call(arg) === '[object Array]';
    };
  }

  // oh, I can't use arrays in params? Fine, I'll create hashes with indexes as keys
  function arrayToObject (a) {
    if (Array.isArray(a)) {
      var o = { faux_array: true };
      for (var i=0; i<a.length; i++) {
        o[i] = arrayToObject(a[i]);
      }
      return o;
    } else {
      return a;
    }
  }

  var dataTable = 
        $('#dances-table').DataTable({
          "processing": true,
          "serverSide": true,
          "ajax": {
            url: $('#dances-table').data('source'),
            data: function(d) {
              // d.figureQuery = arrayToObject(['and', ['none', ['figure', 'gyre']], ['follows', ['figure', 'roll away'], ['figure', 'swing']]]);
              d.figureQuery = arrayToObject(JSON.parse($('#query-buffer').val()));
              // d.figureQuery = arrayToObject(['and']);
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
  // $('#exclude-moves').change(function () { dataTable.draw();});
});
