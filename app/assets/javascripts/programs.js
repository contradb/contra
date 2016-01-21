// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.




(function () {
    var app = angular.module('activities_editor', ['angucomplete-alt']);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.addActivity = function () {
            activities_ctrl.activities.push({});
        };
        $scope.deleteActivity = function() {
            (activities_ctrl.activities.length>0) && activities_ctrl.activities.pop({});
        };
    }
    app.controller('ActivitiesController', ['$scope',scopeInit]);
})()
