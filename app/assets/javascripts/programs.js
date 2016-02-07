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

var dragInitiator = null;       // global variable

function dragEnterOver(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    var tt = ev.currentTarget
    // highlight new
    if (!tt.isEqualNode(dragInitiator)) // global variable
        $(tt).addClass("contra-drop-enthusiastic");
}
function dragExitLeave(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    var tt = ev.currentTarget;
    var $tt = $(tt)
    if ((!ev.relatedTarget) || !tt.contains(ev.relatedTarget))
        $(tt).removeClass("contra-drop-enthusiastic")
}


// browser independent ways to get to the dataTransfer property - I
// think some use one, some use the other.
// Then there's the issue that Set/Get data transfer only suppor text on MS browsers
// which means that to DnD at all we have to accept text, which I don't wanna do. 
// and this fails with some random error. Ugh. 
function eventSetDataTransfer (ev, value) {
    dataTransfer = eventDataTransferProperty(ev);
    try { dataTransfer.setData("contradbActivity", value); }
    catch (e) {
        console.log("warning: drag and drop setData failed.\n\""+
                    e + "\"\nSmells like a Microsoft Browser.\n"+
                    "Retrying with riskier parameters...");
        dataTransfer.setData("text", value);
    }
    return;
}
function eventGetDataTransfer (ev) {
    dataTransfer = eventDataTransferProperty(ev);
    try { 
        var txt = dataTransfer.getData("contradbActivity");
        if (txt && (txt.length>0)) return txt;
        else throw new Error("Got null or nullstring Data, trying another approach...");
    }
    catch (e) {
        console.log("warning: drag and drop getData failed.\n\""+
                    e + "\"\nSmells like a Microsoft Browser.\n"+
                    "Retrying with riskier parameters...");
        var txt = dataTransfer.getData("text");
        if (txt && (txt.length>0)) return txt;
        else throw new Error("Also can't get meaningful text. I give up! See above warning");
    }
}
function eventDataTransferProperty(ev) {
    if (ev.dataTransfer && 
        ev.dataTransfer.setData) 
        return ev.dataTransfer
    else if (ev.originalEvent && 
             ev.originalEvent.dataTransfer && 
             ev.originalEvent.dataTransfer.setData)
        return logThis(ev.originalEvent.dataTransfer, "original dataTransfer");
    else throw new Error( "Can't find dataTransfer property in event");
}



function dragStart(ev) {
    // logThis(ev.target.id, "dragStart");
    dragInitiator = ev.target;                            // assign global variable
    eventDataTransferProperty(ev).effectAllowed = "move";
    // sadly, "contradbActivity" dies in MS Edge with "Element not found". 
    // "text/plain" works. 
    // Don't support until they fix. -dm 02-06-2016
    if (ev && ev.target && ev.target.id && (ev.target.id.length > 0))
    {
        eventSetDataTransfer(ev, ev.target.id); 
        $(ev.target).addClass("contra-drag-origin");
    }
    else throw new Error("Event target has an invalid id.");
}

function drop(ev) {
    console.log("drop begin");
    ev.preventDefault();
    ev.stopPropagation();
    var data = eventGetDataTransfer(ev);
    console.log("drop: "+whatsThis(data)+" on "+whatsThis(ev.currentTarget.id));
    var from = activityRowIndex(data) // index
    console.log("drop Still alive");
    var to   = activityRowIndex(ev.currentTarget.id) // index
    console.log("drop from "+ from + " to "+ to)
    var scope = angular.element($('#activities-div')).scope()
    var activities = scope.getActivities()
    var transplant = activities[from];
    activities.splice(from, 1);           // destructive modify in-place!
    activities.splice(to, 0, transplant); // destructive modify in-place!
    scope.$apply();
    // clean up, especially on this element, but everywhere as a happy side-effect:
    $(".activity-row").removeClass("contra-drop-enthusiastic").removeClass("contra-drag-origin");
    console.log("drop end");
    return;
}


function whatsThis(x) {
    if (typeof x == "undefined")   return "undefined"
    else if (null == x)            return "null";
    else if (typeof x == "string") return '"'+x+'"';
    else if (Array.isArray(x))     return JSON.stringify(x);
    else if (typeof x == "object") return JSON.stringify(x);
    else                           return "thingy "+x;
}

function logThis (x, optionalLabel) {
    optionalLabel = optionalLabel || "logThis";
    console.log(""+optionalLabel+": "+whatsThis(x));
    return x;
}

function activityRowIndex(id) {
    prefix = "activity-row-";
    if (id.slice(0,prefix.length) == prefix)
        return parseInt(id.slice(prefix.length))
    else throw new Error( "called activityRowIndex on something that's not an activity-row id string. It looks like this: "+whatsThis(id));
}

function attachDragAndDropEventHandlers($element) {
    $element.on("dragstart", dragStart).on("drop", drop).on("dragenter", dragEnterOver).on("dragleave", dragExitLeave).on("dragexit", dragExitLeave).on("dragover", dragEnterOver).prop("draggable","true");
}

// Angular init
(function () {
    var app = angular.module('activities_editor', ['angucomplete-alt']);
    var scopeInit = function ($scope) {
        var activities_ctrl = this;
        $scope.findDanceHashById = findDanceHashById
        $scope.addActivity = addActivity;
        $scope.deleteSelectetdActivities = deleteSelectetdActivities;
        $scope.checkedActivityCount = checkedActivityCount;
        $scope.attachDragAndDropEventHandlers = attachDragAndDropEventHandlers
        $scope.getActivities = function () {return activities_ctrl.activities;}
    }
    app.controller('ActivitiesController', ['$scope',scopeInit]);
    app.directive('contraDragAndDropActivities', function($compile) {
        return function (scope, element, attrs) {
            // restrict: 'A',
            scope.attachDragAndDropEventHandlers(element);
        }
    })
})()


/* // jQuery initialization, should there be any, goes here
$(document).ready(function(){
    console.log("jQuery init begin");
    console.log("jQuery init end");
})
*/
