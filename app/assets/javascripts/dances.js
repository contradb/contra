jQuery(document).ready(function() {
  $('#dances-table').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#dances-table').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "title"},
      {"data": "choreographer_name"},
      {"data": "user_name"}
    ]
    // pagingType is optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about
    // available options.
  });
});

$(function () {
  $( "#choreographer-autocomplete" ).autocomplete({
    source: (typeof __choreographers__secret !== 'undefined') && __choreographers__secret,
    autoFocus: true,
    minLength: 0
  });
  $( "#start-type-autocomplete" ).autocomplete({
    source: ["improper","Becket","Becket ccw","four face four","square dance","indecent"],
    autoFocus: true,
    minLength: 0
  });
});

function classesForFigureA1B2(figures, index, open_indicies, is_top) {
  var is_open = open_indicies.indexOf(index) >= 0;
  var start_classes = is_top && indexStartsNewA1B2(figures,index) ? ['new-a1b2'] : [];
  var end_classes = indexEndsDanceSquarely(figures, index) && !(is_open && is_top) ? ['last-a1b2'] : [];
  var selected_classes = is_open ? ['selected-figure'] : []
  return start_classes.concat(end_classes).concat(selected_classes).join(' ');
}

function indexStartsNewA1B2(figures, index) {
  var beat_start = 0;
  for (var i=0; i<index; i++) {
    beat_start += figureBeats(figures[i]);
  }
  var beat_start_is_square = (beat_start % 16 === 0)
  return beat_start_is_square && figureBeats(figures[index]) > 0;
}

function indexEndsDanceSquarely(figures, index) {
  return (index === figures.length - 1) && (sumBeats(figures) % 16 === 0);
}

// =====================================================================================

function defaultFigures (figures) {
    if (figures.length == 0)
        return [newFigure(), newFigure(), newFigure(), newFigure(),
                newFigure(), newFigure(), newFigure(), newFigure()]
    else return figures;
}

// =====================================================================================

function user_changed_parameter (figure, index) {
    var fig_def = defined_events[figure.move];
    if (fig_def && fig_def.props.change)
        fig_def.props.change(figure, index)
}

function user_changed_move (figure) {
    var params = parameters(figure.move);
    figure.parameter_values = [];
    for (var i=0; i<params.length; i++)
        figure.parameter_values[i] = params[i].value
}

function parameter_label (movestring, index) {
  var fig_def = defined_events[movestring];
  var ps = parameters(movestring);
  return (fig_def && fig_def.props && fig_def.props.labels && fig_def.props.labels[index]) ||
    (ps[index] && ps[index].name)
}

// =====================================================================================




// =====================================================================================

function menuMoveLabel(from,to) {
  if (to==from) { return '~'; }
  else if (to < from) { return 'Up '+ (from - to) }
  else { return 'Down '+ (to - from) }
}

// =====================================================================================
// =====================================================================================





(function () {
    var app = angular.module('contra', []);
    var scopeInit = function ($scope,$timeout) {
        var fctrl42 = this;
        $scope.moveCaresAboutRotations = moveCaresAboutRotations;
        $scope.moveCaresAboutPlaces = moveCaresAboutPlaces;
        $scope.degreesToWords = degreesToWords;
        $scope.anglesForMove = anglesForMove;
        $scope.sumBeats = sumBeats;
        $scope.labelForBeats = labelForBeats;
        $scope.classesForFigureA1B2 = classesForFigureA1B2;

        $scope.moves = moves;
        $scope.parameters = parameters;
        $scope.degreesToRotations = degreesToRotations;
        $scope.degreesToPlaces = degreesToPlaces;
        setChoosers($scope);
        $scope.wristGrips = wristGrips;
        $scope.figure_html_readonly = figure_html_readonly;
        $scope.set_if_unset = set_if_unset;
        $scope.user_changed_parameter = user_changed_parameter
        $scope.user_changed_move = user_changed_move
        $scope.parameter_label = parameter_label
        $scope.edit_index_box = []
        $scope.clickFigure = function(figureIdx) {
          if ($scope.edit_index_box[0] === figureIdx) {
            $scope.edit_index_box.length = 0;
          } else {
            $scope.edit_index_box[0] = figureIdx;
            var is_empty_figure = !$scope.figures.arr[figureIdx].move
            if (is_empty_figure) {
              // focus the move select box:
              $timeout(function() { $('#move-'+figureIdx).focus(); });
            }
          }
        }
        $scope.editable_figures = function(figures) {
            idx = $scope.edit_index_box[0]
            return (null != idx) && $scope.figures.arr[idx] ?
                [$scope.figures.arr[idx]] :
                [];
        }

        $scope.toJson = angular.toJson;
        $scope.newFigure = newFigure;
        $scope.addFigure = function() {fctrl42.arr.push(newFigure());};
        $scope.deleteFigure = function() {(fctrl42.arr.length>0) && fctrl42.arr.pop(); $scope.edit_index_box.length=0;};
        $scope.deleteFigureIdx = function(idx) {(idx >= 0) && (fctrl42.arr.length > idx) && fctrl42.arr.splice(idx,1); $scope.edit_index_box.length=0;};
        $scope.duplicateIdx = function(idx) {
            (0 <= idx) && (idx < fctrl42.arr.length) && fctrl42.arr.splice(idx,0,angular.copy(fctrl42.arr[idx]));
            $scope.edit_index_box.length=0;
        }
        $scope.menuMoveLabel = menuMoveLabel
        $scope.menuMove = function(from, to) {fctrl42.arr.splice(to, 0, fctrl42.arr.splice(from, 1)[0]); $scope.edit_index_box.length=0;}
        $scope.rotateFigures = function() {
          (fctrl42.arr.length>0) && fctrl42.arr.unshift(fctrl42.arr.pop());
          $scope.edit_index_box.length=0;
        };
        $scope.defaultFigures = defaultFigures;

        // so not angular, but I'm trying anything at this point. 
        $('.update-dance').on('click', function(e) {
          $('#dance-figures-json').val(JSON.stringify($scope.figures.arr));
        })
    }
  app.controller('FiguresController', ['$scope','$timeout',scopeInit])
})()
