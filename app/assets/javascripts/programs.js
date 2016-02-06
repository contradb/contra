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


var $lastEntered = null;
var dragInitiator = null;
function dragEnter(ev) {
    console.log('dragEnter');
    // erase old
    if ($lastEntered) $lastEntered.removeClass("yellow");

    // store
    $lastEntered = $(ev.currentTarget);
    
    // highlight new
    if (!ev.currentTarget.isEqualNode(dragInitiator))
        $lastEntered.addClass("yellow");
}

function drag(ev) {
    console.log("drag");
    dragInitiator = ev.target;
    ev.dataTransfer.setData("contradbActivity", ev.target.id);
}

function drop(ev) {
    ev.preventDefault();
    var data = ev.dataTransfer.getData("contradbActivity");
    console.log("drop: "+data+" on "+ev.currentTarget.id +(" "+ (ev.offsetY<(ev.currentTarget.offsetHeight/2)?"above":"below")));
    console.log("drop from "+ activityRowIndex(data) + " to "+ activityRowIndex(ev.currentTarget.id) + "arr = " + $('#activities-div').scope().getActivities())
    

}

function activityRowIndex(id) {
    console.log ("activityRowIndex "+ id);
    prefix = "activity-row-";
    if (id.slice(0,prefix.length) == prefix)
        return parseInt(id.slice(prefix.length))
    else throw new Error( "called activityRowIndex on something that's not an activity-row")
}

(function () {
    var app = angular.module('activities_editor', ['angucomplete-alt']);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.findDanceHashById = findDanceHashById
        $scope.addActivity = addActivity;
        $scope.deleteSelectetdActivities = deleteSelectetdActivities;
        $scope.checkedActivityCount = checkedActivityCount;
        $scope.getActivities = function () {return $scope.activities;}
        $scope.setActivities = function (x) {$scope.activities = x;}
    }
    app.controller('ActivitiesController', ['$scope',scopeInit]);
    console.log("got here");
    $('.davedebug').html("foo");
    $('.davedebug').html('html set successful, thanks jQuery');
    console.log("still alive");
})()
