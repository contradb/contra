function installEventHandlers(selector) {
  selector.find('.figure-filter-op').change(filterOpChanged);
  selector.find('.figure-filter-add').click(clickFilterAddSubfilter);
  selector.find('.figure-filter-remove').click(filterRemoveSubfilter);
  selector.find('.figure-filter-move').change(updateQuery);
}

var addButtonHtml = "<button class='figure-filter-add'>Add</button>";
var removeButtonHtml = "<button class='figure-filter-remove'><span class='glyphicon glyphicon-remove'></span></button>";

if (!Array.prototype.forEach) { throw "I was expecting Array.forEach to be defined"; }


var figureMoveHtml = "<select class='figure-filter-move form-control'><option value='*' selected=true>*</option>";
moves().forEach(function(move) {
  var selectedIfChain = ('chain'===move) ? ' selected ' : '';
  figureMoveHtml += "<option value='"+move+"'>"+move+"</option>";
});
figureMoveHtml += "</select>";

var filterHtml = "\
    <div class='figure-filter' data-op=and>\
      <select class='figure-filter-op form-control'>\
        <option value='figure' selected>figure</option>\
        <option value='and'>and</option> \
        <option value='or'>or</option>\
        <option value='follows'>follows</option>\
        <option value='none'>none</option>\
        <option value='all'>all</option>\
        <option value='not'>not</option>\
      </select>"+
      figureMoveHtml+"\
      <span class='figure-filter-end-of-subfigures'></span>\
    </div>";


function maxSubfilterCount(op) {
  switch(op) {
  case 'figure':
    return 0;
  case 'all':
  case 'none':
  case 'not':
    return 1;
  case undefined:
    throw 'missing argument to maxSubfilterCount';
  default:
    return Infinity;
  }
}

function minSubfilterCount(op) {
  switch(op) {
  case 'none':
  case 'all':
  case 'not':
    return 1;
  case undefined:
    throw 'missing argument to minSubfilterCount';
  default:
    return 0;
  }
}

function minUsefulSubfilterCount(op) {
  switch(op) {
  case 'and':
  case 'or':
  case 'follows':
    return 2;
  default:
    return minSubfilterCount(op);
  }
}

function filterOpChanged(e) {
  var opSelect = $(e.target);
  var filter = opSelect.closest('.figure-filter');
  var op = opSelect.val();
  var actualSubfilterCount = filter.children('.figure-filter').length;
  while (actualSubfilterCount > maxSubfilterCount(op)) {
    filter.children('.figure-filter').last().remove();
    actualSubfilterCount--;
  }
  while (actualSubfilterCount < minUsefulSubfilterCount(op)) {
    filterAddSubfilter(filter);
    actualSubfilterCount++;
  }
  if (op === 'figure') {
    addFigureMoveSelect(filter);
  } else {
    filter.children('.figure-filter-move').remove(); // if we were a figure filter
  }
  var hasNoAddButton = filter.children('.figure-filter-add').length === 0;
  if (hasNoAddButton && actualSubfilterCount < maxSubfilterCount(op)) {
    var addButton = $(addButtonHtml);
    addButton.click(clickFilterAddSubfilter);
    filter.children('.figure-filter-end-of-subfigures').after(addButton);
  } else if ((!hasNoAddButton) && actualSubfilterCount >= maxSubfilterCount(op)) {
    filter.children('.figure-filter-add').remove();
  }
  ensureChildRemoveButtons(filter);
  updateAddButtonText(filter, op);
  
  filter.children('.figure-filter').attr('data-op', op);
  updateQuery();
}

function updateAddButtonText(filter, op) {
  filter.children('.figure-filter-add').text('add '+ op);
}

function ensureChildRemoveButtons(filter) {
  var subfilters = filter.children('.figure-filter');
  var op = filter.children('.figure-filter-op').val();
  if (subfilters.length > minSubfilterCount(op)) {
    subfilters.each(function () {
      var $this = $(this);
      if (0 === $this.children('.figure-filter-remove').length) {
        var removeButton = $(removeButtonHtml);
        removeButton.click(filterRemoveSubfilter);
        if ($this.children('.figure-filter').length > 0) {
          $this.children('.figure-filter').first().before(removeButton);
        } else {
          $this.children('.figure-filter-end-of-subfigures').before(removeButton);
        }
      }
    });
  } else if (subfilters.length <= minSubfilterCount(op)) {
    filter.children('.figure-filter').each(function() {
      $(this).children('.figure-filter-remove').remove();
    });
  }
}

function addFigureMoveSelect(filter) {
  var moveSelect = $(figureMoveHtml);
  moveSelect.change(updateQuery);
  filter.children('.figure-filter-op').after(moveSelect);
}

function clickFilterAddSubfilter(e) {
  filterAddSubfilter($(this).closest('.figure-filter'));
}

function filterAddSubfilter(parentFilter) {
  var childFilter = $(filterHtml);
  installEventHandlers(childFilter);
  childFilter.insertBefore(parentFilter.children('.figure-filter-end-of-subfigures'));
  ensureChildRemoveButtons(parentFilter);
  var op = parentFilter.children('.figure-filter-op').val();
  childFilter.attr('data-op', op);
  updateQuery();
}

function filterRemoveSubfilter(e) {
  $(this).closest('.figure-filter').remove();
  updateQuery();
}

var updateQuery;              // defined below...

function buildFigureQuery(figure_filter) {
  figure_filter = $(figure_filter);
  var op = figure_filter.children('.figure-filter-op').val();
  if (op === 'figure') {
    return [op, figure_filter.children('.figure-filter-move').val()];
  } else {
    var kids = figure_filter.children('.figure-filter').get();
    if (!Array.prototype.map) { throw "I was expecting Array.map to be defined"; }
    var filter = kids.map(buildFigureQuery);
    filter.unshift(op);
    return filter;
  }
}

jQuery(document).ready(function() {
  updateQuery = function() {
    $('#figure-query-buffer').val(JSON.stringify(buildFigureQuery($('#figure-filter-root'))));
    if (dataTable) {
      dataTable.draw(); 
    }
  };

  addFigureMoveSelect($('#figure-filter-root'));
  installEventHandlers($('#figure-filter-root'));
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
              d.figureQuery = arrayToObject(JSON.parse($('#figure-query-buffer').val()));
            }
          },
          "pagingType": "full_numbers",
          "dom": 'ft<"row"<"col-sm-6 col-md-3"i><"col-sm-6 col-md-3"l>>pr',
          language: {
            searchPlaceholder: "search by title, choreographer, and user"
          },
          "order": [[ 3, "desc" ]],
          "columns": [
            {"data": "title"},
            {"data": "choreographer_name"},
            {"data": "user_name"},
            {"data": "updated_at"}
          ]
        });
});
