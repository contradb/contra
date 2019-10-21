// Show Page Validator Toggle
// - note that this js also fires on the programs show page - thanks to unintituive asset pipeline behavior

$(function() {
  function validationToggleExec(selector) {
    if (0 === selector.length) {
      return
    } else if (selector.prop("checked")) {
      $("body").removeClass("no-lingo-lines")
    } else {
      $("body").addClass("no-lingo-lines")
    }
  }
  $(".validation-toggle").change(function() {
    validationToggleExec($(this))
  })
  validationToggleExec($(".validation-toggle"))
})

// Show Page Tag Buttons
$(function() {
  function multiplierOtherUserCount($multiplier) {
    return parseInt($multiplier.data("other-user-count"))
  }

  // tag bootstrap slider slide event:
  $('.tag-constellation input[type="checkbox"]').change(function(e) {
    var checked = $(this).is(":checked")
    var constellation = $(this).closest(".tag-constellation")
    var multiplier = constellation.find(".tag-multiplier")
    var dut_count = multiplierOtherUserCount(multiplier) + (checked ? 1 : 0)
    var tag_active = dut_count > 0

    // glyphicon to clock while we wait for ajax
    var glyphicon = constellation.find(".glyphicon")
    var real_glyphicon = glyphicon.data("contra-glyphicon-class")
    glyphicon
      .removeClass(real_glyphicon)
      .removeClass("invisible")
      .addClass("glyphicon-time")

    // strikethrough on/off
    constellation
      .find(".tag-label")
      .toggleClass("tag-label-untagged", !tag_active)

    // update multiplier
    multiplier.text(dut_count === 0 ? "" : dut_count)

    // update sentence
    if (checked) {
      constellation.find(".on-sentence").show()
      constellation.find(".off-sentence").hide()
    } else {
      constellation.find(".on-sentence").hide()
      constellation.find(".off-sentence").show()
    }
  })

  // when ajax completes, replace glyphicon-time with the real glyphicon (or blank)
  $(".tag-checkbox").on("ajax:success", function(e, json) {
    var $this = $(this)
    var created = json.on
    var constellation = $this.closest(".tag-constellation")
    var multiplier = constellation.find(".tag-multiplier")
    var other_user_count = multiplierOtherUserCount(multiplier)
    var all_user_count = other_user_count + (created ? 1 : 0)
    var glyphicon = constellation.find(".glyphicon")
    var real_glyphicon = glyphicon.data("contra-glyphicon-class")
    glyphicon.toggleClass("invisible", all_user_count == 0)
    glyphicon.removeClass("glyphicon-time").addClass(real_glyphicon)
    return true // continue event propagation
  })

  function interceptTagClickAndSendToLogin(e) {
    e.preventDefault()
    e.stopPropagation()
    window.location.href = "/tag-without-login"
  }

  $(".tag-redirect-click-to-login").each(function() {
    // This intercepts the event before the slider can react to it.
    // Not using the jquery helpers because jquery doesn't expose this.
    this.addEventListener("click", interceptTagClickAndSendToLogin, true)
  })
})

// ________________________________________________________________
// Editor below here
$(function() {
  $("#choreographer-autocomplete").autocomplete({
    source:
      typeof __choreographers__secret !== "undefined" &&
      __choreographers__secret,
    autoFocus: true,
    minLength: 0,
  })
  $("#start-type-autocomplete").autocomplete({
    source: [
      "improper",
      "Becket",
      "Becket ccw",
      "proper",
      "four face four",
      "square dance",
      "indecent",
      "triplet",
    ],
    autoFocus: true,
    minLength: 0,
  })
})

function classesForFigureA1B2(figures, index, open_indicies, is_top) {
  var is_open = open_indicies.indexOf(index) >= 0
  var start_classes =
    is_top && indexStartsNewA1B2(figures, index) ? ["new-a1b2"] : []
  var end_classes =
    indexEndsDanceSquarely(figures, index) && !(is_open && is_top)
      ? ["last-a1b2"]
      : []
  return start_classes.concat(end_classes).join(" ")
}

function classesForFigureBeats(figures, index, open_indicies, is_top) {
  var is_open = open_indicies.indexOf(index) >= 0
  var next_is_open = open_indicies.indexOf(index + 1) >= 0
  var top_bottom_classes
  if (is_top) {
    top_bottom_classes =
      is_open || next_is_open
        ? ["beats-column-top"]
        : ["beats-column-top", "beats-column-bottom"]
  } else {
    // is_bottom and presumably is_open
    top_bottom_classes = ["beats-column-bottom"]
  }
  var selected_classes = is_open ? ["selected-figure"] : []
  var dangerous_beats_classes = goodBeatsWithContext(figures, index)
    ? []
    : ["beats-column-danger"]
  return selected_classes
    .concat(top_bottom_classes, dangerous_beats_classes)
    .join(" ")
}

function indexStartsNewA1B2(figures, index) {
  var beat_start = 0
  for (var i = 0; i < index; i++) {
    beat_start += figureBeats(figures[i])
  }
  var beat_start_is_square = beat_start % 16 === 0
  return beat_start_is_square && figureBeats(figures[index]) > 0
}

function indexEndsDanceSquarely(figures, index) {
  return index === figures.length - 1 && sumBeats(figures) % 16 === 0
}

// =====================================================================================

function defaultFigures(figures) {
  if (figures.length == 0) {
    return [
      newFigure(),
      newFigure(),
      newFigure(),
      newFigure(),
      newFigure(),
      newFigure(),
      newFigure(),
      newFigure("progress"),
    ]
  } else {
    return figures.map(function(figure) {
      var f2 = libfigureObjectCopy(figure)
      f2.alias = alias(f2)
      return f2
    })
  }
}

// lots of side effects
function addFigure(figures_arr, edit_index_box) {
  if (edit_index_box.length > 0) {
    var idx = edit_index_box[0]
    if (0 <= idx && idx < figures_arr.length) {
      // valid selection
      figures_arr.splice(idx + 1, 0, newFigure())
      edit_index_box[0]++
      return
    }
  }
  // add on end
  figures_arr.unshift(newFigure())
  edit_index_box[0] = 0
}

// lots of side effects
function deleteFigure(figures_arr, edit_index_box) {
  if (edit_index_box.length > 0) {
    var idx = edit_index_box[0]
    if (0 <= idx && idx < figures_arr.length) {
      figures_arr.splice(idx, 1)
      if (idx >= figures_arr.length) {
        edit_index_box[0]--
      }
      if (0 >= figures_arr.length) {
        edit_index_box.length = 0
      }
      return
    }
  }
}

// =====================================================================================

function userChangedParameter(figure, index) {
  var fig_def = defined_events[figure.move]
  if (!fig_def || !fig_def.props) {
    return
  }
  if (fig_def.props.change) {
    fig_def.props.change(figure, index)
  }
  if (fig_def.props.alias) {
    figure.alias = fig_def.props.alias(figure)
  }
}

function userChangedMove(figure) {
  figure.move = deAliasMove(figure.alias)
  var params = parameters(figure.alias)
  figure.parameter_values = []
  for (var i = 0; i < params.length; i++) {
    figure.parameter_values[i] = params[i].value
  }
}

// =====================================================================================

function menuMoveLabel(from, to) {
  if (to == from) {
    return "~"
  } else if (to < from) {
    return "Up " + (from - to)
  } else {
    return "Down " + (to - from)
  }
}

// =====================================================================================

;(function() {
  var app = angular.module("contra", ["ngSanitize"])
  var scopeInit = function($scope, $timeout) {
    var fctrl42 = this
    var dialect = JSON.parse($("#dialect-json").text())

    $scope.moveCaresAboutRotations = moveCaresAboutRotations
    $scope.moveCaresAboutPlaces = moveCaresAboutPlaces
    $scope.degreesToWords = degreesToWords
    $scope.anglesForMove = anglesForMove
    $scope.sumBeats = sumBeats
    $scope.labelForBeats = labelForBeats
    $scope.classesForFigureA1B2 = classesForFigureA1B2
    $scope.classesForFigureBeats = classesForFigureBeats
    $scope.figureBeats = figureBeats

    // had to memoize moveTermsAndSubstitutionsForSelect because the move select menus were blanking after accordioning
    // https://stackoverflow.com/questions/17116114/how-to-troubleshoot-angular-10-digest-iterations-reached-error/17116322#17116322
    $scope.moveTermsAndSubstitutionsForSelect = moveTermsAndSubstitutionsForSelectMenu(
      dialect
    )
    $scope.parameters = parameters
    $scope.degreesToRotations = degreesToRotations
    $scope.degreesToPlaces = degreesToPlaces
    $scope.chooser = chooser
    $scope.wristGrips = wristGrips
    $scope.dialect = dialect
    $scope.figureToHtml = figureToHtml
    $scope.dialectForFigures = dialectForFigures
    $scope.set_if_unset = set_if_unset
    $scope.userChangedParameter = userChangedParameter
    $scope.userChangedMove = userChangedMove
    $scope.parameterLabel = parameterLabel
    $scope.edit_index_box = []
    $scope.clickFigure = function(figureIdx) {
      if ($scope.edit_index_box[0] === figureIdx) {
        $scope.edit_index_box.length = 0
      } else {
        $scope.edit_index_box[0] = figureIdx
        $timeout(function() {
          $("#move-" + figureIdx).focus()
        }) // focus the move select box
      }
    }
    $scope.editable_figures = function(figures) {
      idx = $scope.edit_index_box[0]
      return null != idx && $scope.figures.arr[idx]
        ? [$scope.figures.arr[idx]]
        : []
    }

    $scope.toJson = angular.toJson
    $scope.newFigure = newFigure
    $scope.addFigure = function() {
      addFigure(fctrl42.arr, $scope.edit_index_box)
    }
    $scope.deleteFigure = function() {
      deleteFigure(fctrl42.arr, $scope.edit_index_box)
    }
    $scope.deleteFigureIdx = function(idx) {
      idx >= 0 && fctrl42.arr.length > idx && fctrl42.arr.splice(idx, 1)
      $scope.edit_index_box.length = 0
    }
    $scope.duplicateIdx = function(idx) {
      0 <= idx &&
        idx < fctrl42.arr.length &&
        fctrl42.arr.splice(idx, 0, angular.copy(fctrl42.arr[idx]))
      $scope.edit_index_box.length = 0
    }
    $scope.toggleProgression = function(idx) {
      if (fctrl42.arr[idx].progression) {
        delete fctrl42.arr[idx].progression
      } else {
        fctrl42.arr[idx].progression = 1
      }
    }
    $scope.hasProgression = function(idx) {
      return fctrl42.arr[idx].progression
    }
    $scope.menuMoveLabel = menuMoveLabel
    $scope.menuMove = function(from, to) {
      fctrl42.arr.splice(to, 0, fctrl42.arr.splice(from, 1)[0])
      $scope.edit_index_box.length = 0
    }
    $scope.rotateFigures = function() {
      fctrl42.arr.length > 0 && fctrl42.arr.unshift(fctrl42.arr.pop())
      $scope.edit_index_box.length = 0
    }
    $scope.defaultFigures = defaultFigures
    $scope.dancerMenuForChooser = dancerMenuForChooser
    $scope.dancerMenuLabel = dancerMenuLabel
    $scope.heyLengthMenu = heyLengthMenu
    $scope.heyLengthSubstitution = heyLengthSubstitution

    // so not angular, but I'm trying anything at this point.
    $(".update-dance").on("click", function(e) {
      $("#dance-figures-json").val(JSON.stringify($scope.figures.arr))
    })
  }
  app.controller("FiguresController", ["$scope", "$timeout", scopeInit])
  app.controller("HookController", [
    "$scope",
    function($scope) {
      var hook = $("#dance-hook-initializer").text()
      $scope.hook = hook
      // probably the wrong controller, buddy. You want the one above
    },
  ])
})()
