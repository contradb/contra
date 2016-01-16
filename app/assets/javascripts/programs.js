// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// alert ('Hello world');

(function () {
    var app = angular.module('activities_editor', []);
    var scopeInit = function ($scope) {
        console.log("hello scopeInit")
    }
    console.log("hello");
    app.controller('ActivitiesController', ['$scope',scopeInit])
})()
