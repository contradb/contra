$(document).ready(function() {
  if ($(".idioms-list").length <= 0) {
    return
  } // this code services the dialect editor page

  function idiomSelect() {
    var $this = $(this)
    var term = $this.val()
    $this.val("")
    makeIdiomEditor(term)
    $this.find('option[value="' + term + '"]').attr("disabled", true)
  }

  $(".new-dancers-idiom").change(idiomSelect)
  $(".new-move-idiom").change(idiomSelect)

  function makeIdiomEditor(term, opt_substitution, opt_id) {
    var authenticityToken = $(
      "#dialect-authenticity-token-seed input[name=authenticity_token]"
    ).val()
    var presumed_server_substitution = opt_substitution || term
    var substitution_id = slugifyTerm(term) + "-substitution"
    var row = $(
      "<tr>" +
        '  <td class="text-right form-inline"><label for="' +
        substitution_id +
        '" class=control-label>' +
        term +
        "</label></td>" +
        '  <td class="idiom-editor-td"></td>' +
        '  <td class="idiom-delete-td"></td>' +
        "</tr>"
    )
    var editor = $(
      '<form accept-charset="UTF-8" class="form-inline idiom-form">' +
        '  <input name="utf8" value="✓" type="hidden">' +
        '  <input name="idiom_idiom[term]" value="' +
        term +
        '" type="hidden" class="idiom-term">' +
        '  <input name="authenticity_token" value="' +
        authenticityToken +
        '" type="hidden">' +
        '  <div class="form-group has-feedback">' +
        '    <input name="idiom_idiom[substitution]" type=text class="idiom-substitution form-control" id="' +
        substitution_id +
        '">' +
        '    <span class="idiom-ajax-status form-control-feedback"></span>' +
        "  </div>" +
        "</form>"
    )
    var status = editor.find(".idiom-ajax-status")
    indicateStatus(status, "glyphicon-ok", "saved")
    if (opt_id) {
      ensureEditorUpdateMode(editor, opt_id)
    }
    row.find(".idiom-editor-td").append(editor)
    row.find(".idiom-delete-td").append(makeIdiomDeleteButton(term))
    $(".idioms-list").append(row)
    editor.find(".idiom-substitution").val(presumed_server_substitution)
    editor
      .find(".idiom-substitution")
      .blur(function() {
        if (
          editor.find(".idiom-substitution").val() !==
          presumed_server_substitution
        ) {
          editor.submit()
        }
      })
      .keyup(function(e) {
        if (e.keyCode == 27) {
          // escape key
          // undo edits
          editor.find(".idiom-substitution").val(presumed_server_substitution)
          indicateStatus(status, "glyphicon-ok", "saved")
        }
      })
      .on("input", function() {
        if (
          editor.find(".idiom-substitution").val() !==
          presumed_server_substitution
        ) {
          indicateStatus(status, "glyphicon-pencil", "unsaved")
        } else {
          indicateStatus(status, "glyphicon-ok", "saved")
        }
      })
    editor.submit(function(event) {
      event.preventDefault()
      presumed_server_substitution = editor.find(".idiom-substitution").val()
      indicateStatus(status, "glyphicon-time", "saving")
      var idiom_id = editor.attr("data-idiom-id")
      $.ajax({
        url: "/idioms/" + (idiom_id || ""),
        type: idiom_id ? "PUT" : "POST",
        data: editor.serialize(),
        success: function(idiomJson, textStatus, jqXHR) {
          indicateStatus(status, "glyphicon-ok", "saved")
          ensureEditorUpdateMode(editor, idiomJson.id)
          adjustForNewDialect()
        },
        error: function(jqXHRXHR, textStatus, errorThrown) {
          indicateStatus(status, "glyphicon-exclamation-sign", "error saving")
        },
      })
    })
  }

  function makeIdiomDeleteButton(term) {
    var form = $(
      "<form>" +
        "  <button type=button id=delete-" +
        slugifyTerm(term) +
        ' class="btn btn-default delete-idiom">' +
        '    <span class="glyphicon glyphicon-remove" aria-label="delete"></span>' +
        "  </button>" +
        "</form>"
    )
    form.find("button").click(function() {
      var container = form.closest("tr")
      var editor = container.find(".idiom-form")
      var idiom_id = editor.attr("data-idiom-id")
      if (!idiom_id) {
        container.remove() // easy case - new record - local only
        updateSelectButtonOptionDisabled()
      } else {
        // hard case - in the db
        var status = editor.find(".idiom-ajax-status")
        indicateStatus(status, "glyphicon-time", "saving")
        $.ajax({
          url: "/idioms/" + idiom_id,
          type: "DELETE",
          success: function() {
            container.remove()
            adjustForNewDialect()
          },
          error: function(jqXHRXHR, textStatus, errorThrown) {
            indicateStatus(
              status,
              "glyphicon-exclamation-sign",
              "error deleting"
            )
          },
        })
      }
    })
    return form
  }

  function ensureEditorUpdateMode(editor, idiom_id) {
    if (!editor || !idiom_id) {
      throw new Error("missing required arg")
    }
    editor.attr("data-idiom-id", idiom_id)
  }

  function indicateStatus(status, glyphiconClassName, ariaLabel) {
    status
      .empty()
      .append(
        '<span class="glyphicon ' +
          glyphiconClassName +
          '" aria-label="' +
          ariaLabel +
          '"></span>'
      )
  }

  // build menus
  dancers().forEach(function(dancer) {
    $(".new-dancers-idiom").append(
      $('<option value="' + dancer + '">' + dancer + "</option>")
    )
  })
  moves().forEach(function(move) {
    $(".new-move-idiom").append(
      $('<option value="' + move + '">' + move + "</option>")
    )
  })

  function rebuildIdiomsList(idiom_json_array) {
    var idiomsList = $(".idioms-list")
    idiomsList.empty()
    $.each(idiom_json_array, function(meh, idiom) {
      makeIdiomEditor(idiom.term, idiom.substitution, idiom.id)
    })
    adjustForNewDialect()
  }

  function adjustForNewDialect() {
    var dialect = scrapeNormalDialect()
    checkRoleRadioButtons()
    updateGyreSubstitutionViews()
    updateSelectButtonOptionDisabled()
    updateManyToOneWarning(dialect)
  }

  function updateGyreSubstitutionViews() {
    var gyreSubstitution = $("#gyre-substitution").val() || ""
    var text = stringIsBlank(gyreSubstitution) ? "gyre" : gyreSubstitution
    $(".gyre-substitution-view").text(text)
  }

  function stringIsBlank(s) {
    return s.replace(/\s/g, "").length === 0
  }

  function updateSelectButtonOptionDisabled() {
    // enable all
    $("select.new-idiom option").attr("disabled", false)
    // disable the ones that are in use by walking the advanced idiom editors
    $("input.idiom-term").each(function() {
      var term = $(this).val()
      $('select.new-idiom option[value="' + term + '"]').attr("disabled", true)
    })
  }

  var checkboxSubstitutions = $.map(
    [
      ["gent", "gents", "lady", "ladies"],
      ["lark", "larks", "raven", "ravens"],
      ["lead", "leads", "follow", "follows"],
      ["man", "men", "woman", "women"],
    ],
    function(roleArr) {
      var gentlespoon = roleArr[0]
      var gentlespoons = roleArr[1]
      var ladle = roleArr[2]
      var ladles = roleArr[3]
      return {
        gentlespoon: gentlespoon,
        gentlespoons: gentlespoons,
        "first gentlespoon": "first " + gentlespoon,
        "second gentlespoon": "second " + gentlespoon,
        ladle: ladle,
        ladles: ladles,
        "first ladle": "first " + ladle,
        "second ladle": "second " + ladle,
      }
    }
  )

  // Walk the DOM and set role button lightedness appropriately. Profiled to take <= 5ms in one incarnation
  function checkRoleRadioButtons() {
    // ladles & gentlespoons is the default, and so it's checked if there are zero substitutuions
    var gentlespoonLadlesChecked = !(
      $("#gentlespoon-substitution").length ||
      $("#gentlespoons-substitution").length ||
      $("#first-gentlespoon-substitution").length ||
      $("#second-gentlespoon-substitution").length ||
      $("#ladle-substitution").length ||
      $("#ladles-substitution").length ||
      $("#first-ladle-substitution").length ||
      $("#second-ladle-substitution").length
    )
    $("#gentlespoons-ladles").prop("checked", gentlespoonLadlesChecked)
    // ladies & gentlemen, larks & ravens, etc are checked if substitutions match exactly
    $.each(checkboxSubstitutions, function(meh, cbsub) {
      var $radio = $("#" + cbsub["gentlespoons"] + "-" + cbsub["ladles"])
      var checkIt = idiomEditorsMatchButtonSubstitution(cbsub)
      $radio.prop("checked", checkIt)
    })
  }

  function idiomEditorsMatchButtonSubstitution(cbsub) {
    var idioms_list = $(".idioms-list tr")
    var matches = 0
    for (var term in cbsub) {
      for (var i = 0; i < idioms_list.length; i++) {
        var tr = $(idioms_list[i])
        if (tr.find(".idiom-term").val() === term) {
          if (tr.find(".idiom-substitution").val() === cbsub[term]) {
            matches++
            break
          } else {
            return false
          }
        }
      }
    }
    var cbsub_length = 0
    for (var term in cbsub) {
      cbsub_length++
    }
    return matches === cbsub_length
  }

  function updateManyToOneWarning(dialect) {
    // dialect is a standard contradb datastructure
    $(".manyToOneWarningContainer").empty()
    if (!dialectIsOneToOne(dialect)) {
      var substitutions_and_terms = dialectOverloadedSubstitutions(dialect)
      var subst_acc = []
      Object.keys(substitutions_and_terms).forEach(function(substitution) {
        substitutions_and_terms[substitution].forEach(function(term) {
          subst_acc.push("<li>" + term + " → " + substitution + "</li>")
        })
      })
      $(".manyToOneWarningContainer").append(
        "<div class='panel panel-danger'><div class=panel-heading><h1 class=panel-title>Slow Down, Velociraptor!</h1></div><div class=panel-body><p>Your dialect maps multiple terms to the same substitution. If you type one of these substitutions, ContraDB won't know which term you meant. Additionally, you may see “duplicates” in your menus that aren't actually duplicates. If you pick the wrong one, users of other dialects will be told the wrong term.</p><p>If you have a compelling reason to do this, reach out to us (see the 'help' menu) so we can try to make things work for you. Otherwise, fix a few of:</p><ul class=no-bullets>" +
          subst_acc.join("") +
          "</ul></div></div>"
      )
    }
  }

  // returns a standard contradb dialect, not the DOM-based frankenstein this page uses
  function scrapeNormalDialect() {
    var dialect = { dancers: {}, moves: {} }
    var dancers_list = dancers()
    var moves_list = moves()
    var hash_for_term = function(term) {
      if (dancers_list.indexOf(term) >= 0) {
        return dialect.dancers
      } else if (moves_list.indexOf(term) >= 0) {
        return dialect.moves
      } else {
        throw new Error("term '" + term + "' is neither move nor dancer. Hrm.")
      }
    }
    $(".idiom-form").each(function() {
      var form = $(this)
      var term = form.find(".idiom-term").val()
      var substitution = form.find(".idiom-substitution").val()
      var hash = hash_for_term(term)
      hash[term] = substitution
    })
    return dialect
  }

  if ($("#dialect-idioms-init").length === 0) {
    throw new Error(
      "Can't initialize page because can't find #dialect-idioms-init"
    )
  }
  rebuildIdiomsList(JSON.parse($("#dialect-idioms-init").text()))

  // reset the whole dialect
  $(".restore-default-dialect-form")
    .on("ajax:error", function() {
      $(".alert").html("Bummer! Error restoring default dialect.")
    })
    .on("ajax:success", function() {
      rebuildIdiomsList([])
      $(".notice").html("Default dialect restored.")
    })

  // change roles with the click of a button
  $(".dialect-express-role-form")
    .on("ajax:error", function() {
      $(".alert").html("Bummer! Error setting role.")
    })
    .on("ajax:success", function(e, idioms, status, xhr) {
      rebuildIdiomsList(idioms)
    })

  // change gyre with a dialog box
  $("#dialect-gyre-modal-form")
    .on("ajax:error", function() {
      $(".alert").html("Bummer! Error setting gyre from modal.")
    })
    .on("ajax:success", function(e, idioms, status, xhr) {
      rebuildIdiomsList(idioms)
    })
    .submit(function(e) {
      $(this)
        .closest(".modal")
        .modal("toggle") // hide dialog
    })

  $(".dialect-express-role-radio")
    .on("ajax:error", function() {
      $(".alert").html("Bummer! Error setting role radio.")
    })
    .on("ajax:success", function(e, idioms, status, xhr) {
      rebuildIdiomsList(idioms)
    })

  $(".dialect-advanced-toggle-button").click(function() {
    $(".dialect-advanced-toggle-button").toggleClass("btn-primary")
    $(".dialect-advanced-content").toggle()
  })
})
