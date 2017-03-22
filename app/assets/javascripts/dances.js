
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

function styleForBeats(beats) {
  return beats%32 < 16 ? 'a1b1' : 'a2b2';
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
    var scopeInit = function ($scope) {
        var fctrl42 = this;
        $scope.moveCaresAboutRotations = moveCaresAboutRotations;
        $scope.moveCaresAboutPlaces = moveCaresAboutPlaces;
        $scope.degreesToWords = degreesToWords;
        $scope.anglesForMove = anglesForMove;
        $scope.sumBeats = sumBeats;
        $scope.labelForBeats = labelForBeats;
        $scope.styleForBeats = styleForBeats;

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
    app.controller('FiguresController', ['$scope',scopeInit])
})()
