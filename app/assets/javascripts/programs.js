// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.




function findDanceHashById_1 (dance_id,dances) {
    if (dance_id)
        for (var i=0; i<dances.length; i++)
            if (dance_id==dances[i].id)
                return dances[i];
    return null;
}

function findDanceHashById (id,dances) {
    console.log("findDanceHashById("+id+", "+dances+")");
    d = findDanceHashById_1(id, dances);
    console.log("findDanceHashById => "+d);
    return d;
}


(function () {
    var app = angular.module('activities_editor', ['angucomplete-alt']);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.findDanceHashById = findDanceHashById
        $scope.addActivity = function () {
            activities_ctrl.activities.push({});
        };
        $scope.deleteActivity = function() {
            (activities_ctrl.activities.length>0) && activities_ctrl.activities.pop({});
        };
    }
    app.controller('ActivitiesController', ['$scope',scopeInit]);
})()
