// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.




function findDanceHashById (dance_id,dances) {
    if (dance_id) // null is supported
        for (var i=0; i<dances.length; i++)
            if (dance_id==dances[i].id)
                return dances[i];
    return null;
}

function deleteSelectetdActivities(activities) {
    i = 0;
    while (i<activities.length)
        if (activities[i].checked)
            activities.splice(i,1)
        else i++;
    return;
}

function addActivity(activities) {
    o = {};
    activities.push(o);
    checkOnlyThisActivity(activities,o)
    return;
}

function checkOnlyThisActivity(activities, activity) {
    for (i=0;i<activities.length;i++)
        activities[i].checked = (activities[i] == activity)
    return;
}
function checkedActivityCount(activities) {
    acc = 0
    for (i=0;i<activities.length;i++)
        if (activities[i].checked)
            acc++;
    return acc;
}


function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    console.log("drag");
    ev.dataTransfer.setData("contradbActivity", ev.target.id);
}

function drop(ev) {
    ev.preventDefault();
    var data = ev.dataTransfer.getData("contradbActivity");
    console.log("drop: "+data+" y: "+ev.offsetY + " height: "+ev.currentTarget.offsetHeight);
}


(function () {
    var app = angular.module('activities_editor', ['angucomplete-alt']);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.findDanceHashById = findDanceHashById
        $scope.addActivity = addActivity;
        $scope.deleteSelectetdActivities = deleteSelectetdActivities;
        $scope.checkedActivityCount = checkedActivityCount;
    }
    app.controller('ActivitiesController', ['$scope',scopeInit]);
})()
