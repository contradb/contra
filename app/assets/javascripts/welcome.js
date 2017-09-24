function installEventHandlers(selector) {
  // console.log('installEventHandlers');
  // console.log(selector);
  selector.find('.figure-filter-op').change(filterOpChanged);
  selector.find('.figure-filter-add').click(filterAddSubfilter);
  selector.find('.figure-move').change(updateQuery);
}

var addButtonHtml = "<button class='figure-filter-add'>Add</button>";


if (!Array.prototype.forEach) { throw "I was expecting Array.forEach to be defined"; }


// figureMoveHtml variable looks like this, but with every move:
// var figureMoveHtml = "\
//       <select class='figure-move'>\
//         <option value='swing'>swing</option>\
//         <option value='chain' selected>chain</option>\
//         <option value='circle'>circle</option>\
//         <option value='right left through'>right left through</option>\
//       </select>";
var figureMoveHtml = "<select class='figure-move'>";
moves().forEach(function(move) {
  var selectedIfChain = ('chain'===move) ? ' selected ' : '';
  figureMoveHtml += "<option value='"+move+"'" + selectedIfChain +">"+move+"</option>";
});
figureMoveHtml += "</select>";


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
      <span class='figure-filter-end-of-subfigures'></span>"+
      figureMoveHtml+"\
    </div>";


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


function filterOpChanged(e) {
  // console.log("filterOpChanged");
  var opSelect = $(e.target);
  var filter = opSelect.closest('.figure-filter');
  var op = opSelect.val();
  // console.log('op = '+op);
  var actualSubfilterCount = filter.children('.figure-filter').length;
  while (actualSubfilterCount > maxSubfilterCount(op)) {
    filter.children('.figure-filter').last().remove();
    actualSubfilterCount--;
  }
  while (actualSubfilterCount < minSubfilterCount(op)) {
    var newFilter = $(filterHtml);
    installEventHandlers(newFilter);
    newFilter.insertBefore(filter.children('.figure-filter-end-of-subfigures'));
    actualSubfilterCount++;
  }
  if (op === 'figure') {
    addFigureMoveSelect(filter);
  } else {
    filter.children('.figure-move').remove(); // if we were a figure filter
  }
  var addButtonCount = filter.children('.figure-filter-add').length;
  if (actualSubfilterCount < maxSubfilterCount(op) && addButtonCount === 0) {
    var addButton = $(addButtonHtml);
    addButton.click(filterAddSubfilter);
    filter.append(addButton);
  } else if (actualSubfilterCount >= maxSubfilterCount(op) && addButtonCount > 0) {
    filter.children('.figure-filter-add').remove();
  }
  updateQuery();
}

function addFigureMoveSelect(filter) {
    var moveSelect = $(figureMoveHtml);
    moveSelect.change(updateQuery);
    filter.append(moveSelect);
}

function filterAddSubfilter(e) {
  var newFilter = $(filterHtml);
  var thisFilter = $(this).closest('.figure-filter');
  installEventHandlers(newFilter);
  newFilter.insertBefore(thisFilter.children('.figure-filter-end-of-subfigures'));
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
  if (op === 'figure') {
    return [op, figure_filter.children('.figure-move').val()];
  } else {
    var kids = figure_filter.children('.figure-filter').get();
    if (!Array.prototype.map) { throw "I was expecting Array.map to be defined"; }
    var filter = kids.map(buildFilter);
    filter.unshift(op);
    return filter;
  }
}

jQuery(document).ready(function() {

  updateQuery = function() {
    // console.log('updateQuery');
    $('#query-buffer').val(JSON.stringify(buildFilter($('#figure-filter-root'))));
    if (dataTable) {
      dataTable.draw(); 
    }
  }

  addFigureMoveSelect($('#figure-filter-root > .figure-filter'));
  updateQuery();
  installEventHandlers($('#figure-filter-root'));

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
