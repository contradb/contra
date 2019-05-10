$(document).ready(function() {
  if (0 === $('#dances-table').length) {
    return;                     // don't do any of this stuff if we're not on a page with a query.
  }

  var dialect = JSON.parse($('#dialect-json').text());

  function installGenericFilterEventHandlers(selector) {
    selector.find('.figure-filter-op').off('change').change(filterOpChanged); // do not double-install filterOpChanged
    selector.find('.figure-filter-add').off('click').click(clickFilterAddSubfilter); // do not double-install clickFilterAddSubfilter
    selector.find('.figure-filter-remove').off('click').click(filterRemoveSubfilter); // do not double-install filterRemoveSubfilter
    // selector.find('.figure-filter-move').change(updateQuery); // removed because now done by constellation
  }

  var addButtonHtml = "<button class='figure-filter-add'>Add</button>";
  var removeButtonHtml = "<button class='figure-filter-remove'><span class='glyphicon glyphicon-remove'></span></button>";

  if (!Array.prototype.forEach) { throw "I was expecting Array.forEach to be defined"; }
  if (!Array.prototype.map) { throw "I was expecting Array.map to be defined"; }

  var figureMoveHtml = "<select class='figure-filter-move form-control'><option value='*' selected=true>any figure</option>";
  moveTermsAndSubstitutionsForSelectMenu(dialect).forEach(function(move) {
    figureMoveHtml += '<option value="'+move.term+'">'+move.substitution+'</option>';
  });
  figureMoveHtml += "</select>";

  var filterHtml = "\
    <div class='figure-filter' data-op=and>\
      <select class='figure-filter-op form-control'>\
        <option selected>figure</option>\
        <option>formation</option>\
        <option>progression</option>\
        <option>or</option>\
        <option>and</option> \
        <option>&</option> \
        <option>then</option>\
        <option>no</option>\
        <option>not</option>\
        <option>all</option>\
        <option value='count'>number of</option>\
      </select>\
      <span class='figure-filter-end-of-subfigures'></span>\
    </div>";

  var formationSelectHtml = "<select class='figure-filter-formation form-control'>"+['improper','Becket *', 'Becket cw', 'Becket ccw', 'proper', 'everything else'].map(function(label) {return '<option>'+label+'</option>';}).join('')+"</select>";

  var n_ary_helper = ['or', 'and', '&', 'then'];

  // returns true if an operator takes any number of arguments
  function n_ary(op) {
    return n_ary_helper.indexOf(op) >= 0;
  }

  function unary(op) {
    return op === 'no' || op === 'not' || op === 'all' || op === 'count' || op === 'progression';
  }

  function maxParameterCount(op) {
    switch(op) {
    case 'figure':
    case 'formation':
    case 'progression':
      return 0;
    case 'no':
    case 'not':
    case 'all':
    case 'count':
      return 1;
    case undefined:
      throw 'missing argument to maxParameterCount';
    default:
      if (n_ary(op)) {
        return Infinity;
      } else {
        throw new Error('unknown operator: '+op);
      }
    }
  }

  function minParameterCount(op) {
    switch(op) {
    case 'figure':
    case 'progression':
    case 'formation':
      return 0;
    case 'no':
    case 'not':
    case 'all':
    case 'count':
      return 1;
    case undefined:
      throw 'missing argument to minParameterCount';
    default:
      if (n_ary(op)) {
        return 0;
      } else {
        throw new Error('unknown operator: '+op);
      }
    }
  }

  function minUsefulParameterCount(op) {
    return n_ary(op) ? 2 : minParameterCount(op);
  }

  function clickEllipsis(e) {
    var $dotdotdot = $(this);
    $dotdotdot.toggleClass('ellipsis-expanded');
    $dotdotdot.siblings('.figure-filter-accordion').toggle();
    updateQuery();
  }

  function filterOpChanged(e) {
    var opSelect = $(e.target);
    var filter = opSelect.closest('.figure-filter');
    var op = opSelect.val();
    var actualSubfilterCount = filter.children('.figure-filter').length;
    while (actualSubfilterCount > maxParameterCount(op)) {
      filter.children('.figure-filter').last().remove();
      actualSubfilterCount--;
    }
    while (actualSubfilterCount < minUsefulParameterCount(op)) {
      filterAddSubfilter(filter);
      actualSubfilterCount++;
    }
    if (op === 'figure') {
      addFigureFilterMoveConstellation(filter);
    } else {
      removeFigureFilterMoveConstellation(filter);
    }
    if (op === 'formation') {
      addFormationFilterConstellation(filter);
    } else {
      removeFormationFilterConstellation(filter);
    }
    if (op === 'count') {
      addCountFilterConstellation(filter);
    } else {
      removeCountFilterConstellation(filter);
    }
    var hasNoAddButton = filter.children('.figure-filter-add').length === 0;
    // this code largely duplicated in buildDOMtoMatchQuery
    if (hasNoAddButton && actualSubfilterCount < maxParameterCount(op)) {
      var addButton = $(addButtonHtml);
      addButton.click(clickFilterAddSubfilter);
      filter.children('.figure-filter-end-of-subfigures').after(addButton);
    } else if ((!hasNoAddButton) && actualSubfilterCount >= maxParameterCount(op)) {
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
    if (subfilters.length > minParameterCount(op)) {
      subfilters.each(function () {
        var $subfilter = $(this);
        if (0 === $subfilter.children('.figure-filter-remove').length) {
          var removeButton = $(removeButtonHtml);
          removeButton.click(filterRemoveSubfilter);
          if ($subfilter.children('.figure-filter').length > 0) {
            $subfilter.children('.figure-filter').first().before(removeButton);
          } else {
            $subfilter.children('.figure-filter-end-of-subfigures').before(removeButton);
          }
        }
      });
    } else if (subfilters.length <= minParameterCount(op)) {
      filter.children('.figure-filter').each(function() {
        $(this).children('.figure-filter-remove').remove();
      });
    }
  }

  function removeFigureFilterMoveConstellation(filter) {
    filter.children('.figure-filter-move').remove();
    filter.children('.figure-filter-ellipsis').remove();
    filter.children('.figure-filter-accordion').remove();
  }

  function addFigureFilterMoveConstellation(filter) {
    filter
      .append(makeFigureFilterAccordion(filter)) // even to the right of the 'X'
      .children('.figure-filter-op')
      .after(makeFigureFilterEllipsisButton(filter)) // 2 right of figure-filter-op
      .after(makeFigureFilterMoveSelect(filter));    // 1 right of figure-filter-op
  }

  function makeFigureFilterMoveSelect(filter) {
    return $(figureMoveHtml).change(function () {
      var $move = $(this);
      var move = $move.val();
      var $accordion = $move.siblings('.figure-filter-accordion');
      var defaultParameterValues = move != '*' && isAlias(move) ? aliasFilter(move) : null;
      populateAccordionForMove($accordion, move, defaultParameterValues);
      updateQuery();
    });
  }

  function makeFigureFilterEllipsisButton(filter) {
    return $("<button class='btn btn-default figure-filter-ellipsis'>...</button>").click(clickEllipsis);
  }

  function makeFigureFilterAccordion(filter) {
    return $("<table class='figure-filter-accordion'></table>").hide();
  }

  function removeFormationFilterConstellation(filter) {
    filter.children('.figure-filter-formation').remove();
  }

  function addFormationFilterConstellation(filter) {
    filter
      .children('.figure-filter-op')
      .after($(formationSelectHtml).change(updateQuery));
  }

  function removeCountFilterConstellation(filter) {
    filter.children('.figure-filter-count-comparison').remove();
    filter.children('.figure-filter-count-number').remove();
  }

  function addCountFilterConstellation(filter) {
    filter
      .children('.figure-filter-op')
      .after($('<select class="figure-filter-count-number form-control"><option>0</option><option>1</option><option selected>2</option><option>3</option><option>4</option><option>5</option><option>6</option><option>7</option><option>8</option></select>').change(updateQuery))
      .after($('<select class="figure-filter-count-comparison form-control"><option>≥</option><option>≤</option><option>&gt;</option><option>&lt;</option><option>=</option><option>≠</option></select>').change(updateQuery));

  }

  // ================================================================


  var chooserNameWidgetType = {};   // chooser_names to widget types
  var chooserNameToFilterHtml = {}; // chooser_names keys

  if (!Array.isArray) {
    Array.isArray = function(arg) {
      return Object.prototype.toString.call(arg) === '[object Array]';
    };
  }

  function chooserRadioButtons(chooser_name, options, opt_inline) {
    if (opt_inline === undefined) {opt_inline = options.length <= 3;}
    chooserNameWidgetType[chooser_name] = 'radio';
    var div_start = opt_inline ? "" : "<div class=radio>";
    var div_end = opt_inline ? "" : '</div>';
    var label_class = opt_inline ? 'radio-inline' : '';
    chooserNameToFilterHtml[chooser_name] = function(move) {
      var name = generateUniqueNameForRadio();
      var first_time = true;
      var radios = options.map(function(dancer){
        var value = Array.isArray(dancer) ? dancer[0] : dancer;
        var label = Array.isArray(dancer) ? dancer[1] : dancer;
        var checked = first_time ? 'checked=checked' : '';
        first_time=false;
        return div_start+"<label class="+label_class+"><input type='radio' name='"+name+"' value='"+value+"' "+checked+" />"+label+"</label>"+div_end;
      });
      return "<div class='chooser-argument'>"+radios.join('')+"</div>";
    };
  }

  function chooserSelect(chooser_name, options) {
    chooserNameWidgetType[chooser_name] = 'select';
    chooserNameToFilterHtml[chooser_name] = function (move) {
      var htmls = options.map(function(b) {
        var b_value = Array.isArray(b) ? b[0] : b;
        var b_label = Array.isArray(b) ? b[1] : b;
        return '<option value="'+b_value+'">'+b_label+'</option>';
      });
      return '<select class="form-control chooser-argument">'+htmls.join()+'</select>';
    };
  }

  chooserNameWidgetType['chooser_revolutions'] = 'select';
  chooserNameWidgetType['chooser_places'] = 'select';

  chooserNameToFilterHtml['chooser_revolutions'] =
    chooserNameToFilterHtml['chooser_places'] = function(move) {
      var options = ['<option value="*">*</option>'].concat(
        anglesForMove(move).map(function(angle) {
          return '<option value="'+angle.toString()+'">'+degreesToWords(angle,move)+'</option>';
        }));
      return '<select class="form-control chooser-argument">'+options.join()+'</select>';
    };

  chooserSelect('chooser_beats', ['*',8,16,0,1,2,3,4,6,8,10,12,14,16,20,24,32,48,64]);

  chooserRadioButtons('chooser_boolean', ['*',[true, 'yes'], [false, 'no']]);

  { // dancer chooser menus
    var dcs = dancerChooserNames();
    for (var i=0; i < dcs.length; i++) {
      var substituter = function(dancers) { return [dancers, dancerMenuLabel(dancers, dialect)]; };
      chooserSelect(dcs[i], ['*'].concat(dancerCategoryMenuForChooser(chooser(dcs[i])).map(substituter)));
    }
  }

  chooserRadioButtons('chooser_spin', ['*',[true, 'clockwise'], [false, 'ccw']]);
  chooserRadioButtons('chooser_left_right_spin', ['*',[true, 'left'], [false, 'right']]);
  chooserRadioButtons('chooser_right_left_hand', ['*',[false, 'left'], [true, 'right']]);
  chooserRadioButtons('chooser_right_left_shoulder', ['*',[false, 'left'], [true, 'right']]);

  chooserNameToFilterHtml['chooser_text'] = function(move) {
    return '<input class="form-control chooser-argument" type="string" placeholder="words...">';
  };

  // Below splicing ugliness is because we take values from JSLibFigure varaible 'wristGrips' rather than
  // just saying what we mean. At time of writing the following two lines are equivalent.
  // chooserSelect('chooser_star_grip', ['*',['', 'unspecified'],'wrist grip','hands across']);
  chooserSelect('chooser_star_grip', ['*'].concat(wristGrips.map(function(grip) { return (grip === '') ? ['', 'unspecified'] : grip; })));

  chooserSelect('chooser_march_facing', ['*','forward','backward','forward then backward']);

  chooserRadioButtons('chooser_slide', ['*',[true, 'left'], [false, 'right']]);
  chooserSelect('chooser_set_direction', ['*',['along', 'along the set'], ['across', 'across the set'], 'right diagonal', 'left diagonal']);
  chooserSelect('chooser_set_direction_acrossish', ['*', ['across', 'across the set'], 'right diagonal', 'left diagonal']);
  chooserSelect('chooser_set_direction_grid', ['*',['along', 'along the set'], ['across', 'across the set']]);
  chooserSelect('chooser_set_direction_figure_8', ['*','','above','below','across']);

  chooserSelect('chooser_gate_direction', ['*',['up', 'up the set'], ['down', 'down the set'], ['in', 'into the set'], ['out', 'out of the set']]);
  chooserSelect('chooser_slice_return', ['*', ['straight', 'straight back'], ['diagonal', 'diagonal back'], 'none']);
  chooserRadioButtons('chooser_slice_increment', ['*', 'couple', 'dancer']);

  chooserSelect('chooser_all_or_center_or_outsides', ['*', 'all', 'center', 'outsides']);

  chooserSelect('chooser_down_the_hall_ender',
                ['*',
                 ['turn-alone', 'turn alone'],
                 ['turn-couple', 'turn as a couple'],
                 ['circle', 'bend into a ring'],
                 ['cozy', 'form a cozy line'],
                 ['cloverleaf', 'bend into a cloverleaf'],
                 ['thread-needle', 'thread the needle'],
                 ['right-high', 'right hand high, left hand low'],
                 ['sliding-doors', 'sliding doors'],
                 ['', 'unspecified']]);

  chooserSelect('chooser_zig_zag_ender', ['*', ['', 'none'], ['ring', 'into a ring'], ['allemande', 'training two catch hands']]);

  chooserRadioButtons('chooser_go_back', ['*', [true, 'forward &amp; back'], [false, 'forward']]);
  chooserRadioButtons('chooser_give', ['*', [true,'give &amp; take'], [false,'take']]);
  chooserRadioButtons('chooser_half_or_full', ['*', [0.5,'half'], [1.0,'full']]);

  chooserSelect('chooser_hey_length',
                ['*',
                 'full',
                 'half',
                 'less than half',
                 'between half and full']);

  // additional choosers go here -dm 11-24-2017
  if ($(window).width() < 768) {
    chooserSelect('chooser_swing_prefix', ['*', 'none', 'balance', 'meltdown']);
  } else {
    chooserRadioButtons('chooser_swing_prefix', ['*', 'none', 'balance', 'meltdown'], 'inline');
  }


  function doesChooserFilterUseSelect(chooser) {
    if (!chooser.name) { throw_up('expected a chooser, got ' + JSON.stringify(chooser)); }
    return 'select' === chooserNameWidgetType[chooser.name];
  }

  function doesChooserFilterUseRadio(chooser) {
    if (!chooser.name) { throw_up('expected a chooser, got ' + JSON.stringify(chooser)); }
    return 'radio' === chooserNameWidgetType[chooser.name];
  }

  var _uniqueNameForRadioCounter = 9000;
  function generateUniqueNameForRadio() {
    return 'uniqueNameForRadio' + _uniqueNameForRadioCounter++;
  }

  function populateAccordionForMove(accordion, move, optionalParameterValues) {
    optionalParameterValues = optionalParameterValues || [];
    accordion.children().remove();
    var formals = isMove(move) ? parameters(move) : [];
    formals.forEach(function(formal, index) {
      var html_fn = chooserNameToFilterHtml[formal.ui.name] || function() {return '<div>'+formal.name+'</div>';};
      var $chooser = $(html_fn(move));
      if (index < optionalParameterValues.length) {
        var v = optionalParameterValues[index];
        if (chooserNameWidgetType[formal.ui.name] === 'radio') {
          $chooser.find("[value='"+v+"']").prop('checked', true);
        } else {
          $chooser.val(v);
        }
      }
      $chooser.change(updateAlias).change(updateQuery); // note the order
      var chooser_td = $('<td></td>');
      chooser_td.append($chooser);
      var label = $('<tr class="chooser-row"><td class="chooser-label-text">'+ parameterLabel(move, index) +'</td></tr>');
      label.append(chooser_td);
      accordion.append(label);
    });
  }

  function updateAlias() {
    var figure_filter = $(this).closest('.figure-filter');
    var figure = figureFilterToFigure(figure_filter);
    var corrected_alias = alias(figure);
    var move_select = figure_filter.children('.figure-filter-move');
    if (corrected_alias != move_select.val()) {
      move_select.val(corrected_alias);
    }
  }

  function clickFilterAddSubfilter(e) {
    filterAddSubfilter($(this).closest('.figure-filter'));
    updateQuery();
  }

  function filterAddSubfilter(parentFilter) { // caller is responsible to updateQuery() when done
    var childFilter = $(filterHtml);
    installGenericFilterEventHandlers(childFilter);
    addFigureFilterMoveConstellation(childFilter);
    childFilter.insertBefore(parentFilter.children('.figure-filter-end-of-subfigures'));
    ensureChildRemoveButtons(parentFilter);
    var op = parentFilter.children('.figure-filter-op').val();
    childFilter.attr('data-op', op);
  }

  function filterRemoveSubfilter(e) {
    $(this).closest('.figure-filter').remove();
    updateQuery();
  }

  var updateQuery;              // defined below...

  function figureFilterToFigure(figure_filter) {
    var query = buildFigureQuery(figure_filter);
    var move = deAliasMove(query[1]);
    var parameter_values= query.slice(2).map(destringifyFigureFilterParam);
    var figure = {move: move, parameter_values: parameter_values};
    return figure;
  }

  function buildFigureQuery(figure_filter) {
    figure_filter = $(figure_filter);
    var op = figure_filter.children('.figure-filter-op').val();
    if (op === 'figure') {
      var move = figure_filter.children('.figure-filter-move').val();
      var a = [op, move];
      if (accordionIsHidden(figure_filter)) {
        return a;
      }
      var formals = isMove(move) ? parameters(move) : [];
      formals.forEach(function(formal, i) {
        const $chooser = $(figure_filter.children('.figure-filter-accordion').find('.chooser-row')[i]).find('.chooser-argument');
        if (doesChooserFilterUseSelect(formal.ui)) {
          var val = $chooser.val();
          a.push(val);
        } else if (doesChooserFilterUseRadio(formal.ui)) {
          var val = $chooser.find('input:checked').val();
          a.push(val);
        } else if (chooser('chooser_text') === formal.ui) {
          var text = $chooser.val();
          a.push(text);
        } else { // add complicated choosers here
          a.push('*');
        }
      });
      return a;
    } else if (op === 'formation') {
      var formation = figure_filter.children('.figure-filter-formation').val();
      return [op, formation];
    } else if (n_ary(op) || unary(op)) {
      var kids = figure_filter.children('.figure-filter').get();
      var filter = kids.map(buildFigureQuery);
      filter.unshift(op);
      if (op === 'count') {
        filter.push(figure_filter.children('.figure-filter-count-comparison').val());
        filter.push(figure_filter.children('.figure-filter-count-number').val());
      }
      return filter;
    } else {
      throw new Error('unknown operator: '+op);
    }
  }

  function accordionIsHidden($figure_filter) {
    return ! $figure_filter.children('.figure-filter-accordion').is(':visible');
  }

  function buildDOMtoMatchQuery(query) {
    var op = query[0];
    var figureFilter = $(filterHtml);
    figureFilter.children('.figure-filter-op').val(op);
    switch(op) {
    case 'figure':
      addFigureFilterMoveConstellation(figureFilter);
      figureFilter.children('.figure-filter-move').val(query[1]);
      if (query.length > 2) {
        // ... was clicked
        figureFilter.children('.figure-filter-ellipsis').toggleClass('ellipsis-expanded');
        var accordion = figureFilter.children('.figure-filter-accordion');
        accordion.show();
        populateAccordionForMove(accordion, query[1], query.slice(2));
      }
      break;
    case 'formation':
      addFormationFilterConstellation(figureFilter);
      figureFilter.children('.figure-filter-formation').val(query[1]);
      break;
    case 'count':
      var subfilter  = query[1];
      var comparison = query[2];
      var number     = query[3];
      addCountFilterConstellation(figureFilter);
      figureFilter.children('.figure-filter-count-comparison').val(comparison);
      figureFilter.children('.figure-filter-count-number').val(number);
      figureFilter.children('.figure-filter-end-of-subfigures').before(buildDOMtoMatchQuery(subfilter));
      break;
    case 'progression':
      break;
    default:
      if (n_ary(op) || unary(op)) {
        if ('count' === op) { throw_up("count is a special case supposedly already handled"); }
        for (var i=1; i<query.length; i++) {
          figureFilter.children('.figure-filter-end-of-subfigures').before(buildDOMtoMatchQuery(query[i]));
        }
      } else {
        throw new Error('unknown operator: '+op);
      }
      break;
    }
    ensureChildRemoveButtons(figureFilter);
    installGenericFilterEventHandlers(figureFilter);
    figureFilter.children('.figure-filter').attr('data-op', op);
    if (figureFilter.children('.figure-filter').length < maxParameterCount(op)) {
      // this code largely duplicate in filterOpChanged
      var addButton = $(addButtonHtml);
      addButton.click(clickFilterAddSubfilter);
      figureFilter.children('.figure-filter-end-of-subfigures').after(addButton);
      updateAddButtonText(figureFilter, op);
    }
    return figureFilter;
  }

  ////////////////////// VIS TOGGLES
  // For each column in the datatable, add a corresponding button that
  // changes color and toggles column visibility when clicked.

  // duplicated code in search.js
  function insertVisToggles(dataTable) {
    var visToggles = $('.table-column-vis-toggles');
    visToggles.empty();
    $('#dances-table thead th').each(function(index) {
      var link = $("<button class='toggle-vis toggle-vis-active btn btn-xs' href='javascript:void(0)'>"+$(this).text()+"</button>");
      link.click(function () {
        var column = dataTable.column(index);
        var activate = !column.visible();
        column.visible(activate);
        if (activate) {
          link.addClass('toggle-vis-active');
          link.removeClass('toggle-vis-inactive');
        } else {
          link.addClass('toggle-vis-inactive');
          link.removeClass('toggle-vis-active');
        }
      });
      visToggles.append(link);
    });
  }

  // duplicated code in search.js
  var tinyScreenColumns = ['Title', 'Choreographer'];
  var narrowScreenColumns = tinyScreenColumns.concat(['Hook']);
  var wideScreenColumns = narrowScreenColumns.concat(['Formation', 'User', 'Entered']);
  var recentlySeenColumns = null;

  // duplicated code in search.js
  function toggleColumnVisForResolution(dataTable, width) {
    var screenColumns = (width < 400) ? tinyScreenColumns : ((width < 768) ? narrowScreenColumns : wideScreenColumns);
    if (recentlySeenColumns === screenColumns) { return; }
    recentlySeenColumns = screenColumns;
    $('.table-column-vis-toggles button').each(function(index) {
      var $this = $(this);
      var text = $this.text();
      if (0 <= screenColumns.indexOf(text)) {
        dataTable.column(index).visible(true);
        $this.removeClass('toggle-vis-inactive');
        $this.addClass('toggle-vis-active');
      } else {
        dataTable.column(index).visible(false);
        $this.addClass('toggle-vis-inactive');
        $this.removeClass('toggle-vis-active');
      }
    });
  }

  updateQuery = function() {
    var fq = buildFigureQuery($('#figure-filter-root'));
    $('#figure-query-buffer').val(JSON.stringify(fq));
    $('.figure-query-sentence').text(buildFigureSentence(fq, dialect));
    if (dataTable) {
      dataTable.draw();
    }
  };

  if (''===$('#figure-query-buffer').val()) {
    // first time visiting the page, e.g. not returning via browser 'back' button
    var root = $(filterHtml);
    root.attr('id', 'figure-filter-root');
    $('#figure-filter-root-container').append(root);
    addFigureFilterMoveConstellation(root);
    installGenericFilterEventHandlers(root);
    updateQuery();
  } else {
    // back button pressed -> rebuilding the dom from figure query buffer
    var fq = JSON.parse($('#figure-query-buffer').val());
    var root = buildDOMtoMatchQuery(fq);
    $('#figure-filter-root-container').append(root);
    root.attr('id', 'figure-filter-root');
    $('.figure-query-sentence').text(buildFigureSentence(fq, dialect));
  }

  // oh, I can't use arrays in params? Fine, I'll create hashes with indexes as keys
  function arrayToIntHash (a) {
    if (Array.isArray(a)) {
      var o = { faux_array: true };
      for (var i=0; i<a.length; i++) {
        o[i] = arrayToIntHash(a[i]);
      }
      return o;
    } else {
      return a;
    }
  }

  // duplicated code in search.js
  var dataTable =
        $('#dances-table').DataTable({
          "processing": true,
          "serverSide": true,
          "ajax": {
            url: $('#dances-table').data('source'),
            type: 'POST',
            data: function(d) {
              // d.figureQuery = arrayToIntHash(['and', ['no', ['figure', 'gyre']], ['then', ['figure', 'roll away'], ['figure', 'swing']]]);
              d.figureQuery = arrayToIntHash(JSON.parse($('#figure-query-buffer').val()));
            }
          },
          "pagingType": "full_numbers",
          "dom": 'f<"table-column-vis-wrap"<"table-column-vis-toggles">>t<"row"<"col-sm-6 col-md-3"i><"col-sm-6 col-md-3"l>>pr',
          language: {
            searchPlaceholder: "filter by title, choreographer, and user"
          },
          "columns": [          // mapped, in order, to <th> ordering in the html.erb
            {"data": "title"},
            {"data": "choreographer_name"},
            {"data": "hook"},
            {"data": "formation"},
            {"data": "user_name"},
            {"data": "created_at"},
            {"data": "updated_at"},
            {"data": "published"},
            {"data": "figures"}
          ],
          "order": [[ 5, "desc" ]] // 5 should = index of 'created_at' in the array above
        });

  // duplicated code in search.js
  if (0===$('.table-column-vis-wrap label').length) {
    $('.table-column-vis-wrap').prepend($('<label>Show columns </label>'));
  }
  insertVisToggles(dataTable);
  var resizeFn = function () {
    toggleColumnVisForResolution(dataTable, $(window).width());
  };
  $(window).resize(resizeFn);
  resizeFn();
});
