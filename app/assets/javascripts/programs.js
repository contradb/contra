// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// alert ('Hello world');

(function () {
    var app = angular.module('activities_editor', []);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.addActivity = function() {activities_ctrl.arr.push({});};
        $scope.deleteActivity = function() {
            (activities_ctrl.arr.length>0) && activities_ctrl.arr.pop({});
        };
    }
    console.log("hello");
    app.controller('ActivitiesController', ['$scope',scopeInit])
})()
