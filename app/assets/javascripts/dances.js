
function styleForBeats(beats) {
    return beats%32 < 16 ? 'a1b1' : 'a2b2' 
}


// always freshly allocated
function newFigure () {
    return { parameter_values: [] }
}

function defaultFigures (figures) {
    if (figures.length == 0)
        return [newFigure(), newFigure(), newFigure(), newFigure(),
                newFigure(), newFigure(), newFigure(), newFigure()]
    else return figures;
}


// =====================================================================================
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

function parameter_glue (movestring, index) {
    var fig_def = defined_events[movestring];
    return (fig_def && fig_def.props && fig_def.props.glue && fig_def.props.glue[index]) || ""
}

// =====================================================================================



;


// =====================================================================================


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
        $scope.figure_html_readonly = figure_html_readonly;
        $scope.set_if_unset = set_if_unset;
        $scope.user_changed_parameter = user_changed_parameter
        $scope.user_changed_move = user_changed_move
        $scope.parameter_glue = parameter_glue
        $scope.edit_index_box = [null]
        $scope.editable_figures = function(figures) {
            idx = $scope.edit_index_box[0]
            return Number.isInteger(idx) && $scope.figures.arr[idx] ?
                [$scope.figures.arr[idx]] :
                [];
        }

        $scope.toJson = angular.toJson;
        $scope.newFigure = newFigure;
        $scope.addFigure = function() {fctrl42.arr.push(newFigure());};
        $scope.deleteFigure = function() {(fctrl42.arr.length>0) && fctrl42.arr.pop()};
        $scope.rotateFigures = function() {
            (fctrl42.arr.length>0) && 
                fctrl42.arr.unshift(fctrl42.arr.pop())
        };
        $scope.defaultFigures = defaultFigures;
    }
    app.controller('FiguresController', ['$scope',scopeInit])
})()
