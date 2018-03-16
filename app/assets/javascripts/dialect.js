$(document).ready(function() {
  if ($('.idioms-list').length <= 0) {return;} // this code services the dialect editor page

  $('.new-dancers-idiom').change(function(e) {
    console.log("TODO "+$(this).val());
  });

  $('.new-move-idiom').change(function() {
    var term = $(this).val();
    makeIdiomEditor(term);
  });

  function makeIdiomEditor(term, opt_substitution, opt_id) {
    var authenticityToken = $('#authenticity-token-incubator input[name=authenticity_token]').val();
    var presumed_server_substitution = opt_substitution || term;
    var substitution_id = slugifyTerm(term) + '-substitution';
    var row =
          $('<tr><td class="text-right form-inline"><label for="' + substitution_id + '" class=control-label>' +
            term + '</label></td><td class="idiom-editor-td"></td><td class="idiom-delete-td"></td></tr>');
    var editor =
          $('<form accept-charset="UTF-8" class="form-inline idiom-form">' +
            '  <input name="utf8" value="✓" type="hidden">' +
            '  <input name="idiom_idiom[term]" value="' + term + '" type="hidden" class="idiom-term">' +
            '  <input name="authenticity_token" value="' + authenticityToken +'" type="hidden">' +
            '  <div class="form-group has-feedback">' +
            '    <input name="idiom_idiom[substitution]" type=text class="idiom-substitution form-control" id="' + substitution_id + '">' +
            '    <span class="idiom-ajax-status form-control-feedback"></span>' +
            '  </div>' +
            '</form>');
    var status = editor.find('.idiom-ajax-status');
    indicateStatus(status, 'glyphicon-ok', 'saved');
    if (opt_id) { ensureEditorUpdateMode(editor, opt_id); }
    row.find('.idiom-editor-td').append(editor);
    row.find('.idiom-delete-td').append(makeIdiomDeleteButton(term));
    $('.idioms-list').append(row);
    editor.find('.idiom-substitution').val(presumed_server_substitution);
    editor.find('.idiom-substitution').blur(function () {
      if (editor.find('.idiom-substitution').val() !== presumed_server_substitution) {
        editor.submit();
      }
    }).keyup(function(e) {
      if (e.keyCode == 27) {    // escape key
        // undo edits
        editor.find('.idiom-substitution').val(presumed_server_substitution);
        indicateStatus(status, 'glyphicon-ok', 'saved');
      }
    }).on('input', function () {
      if (editor.find('.idiom-substitution').val() !== presumed_server_substitution) {
        indicateStatus(status, 'glyphicon-pencil', 'unsaved');
      } else {
        indicateStatus(status, 'glyphicon-ok', 'saved');
      }
    });
    editor.submit(function(event) {
      event.preventDefault();
      presumed_server_substitution = editor.find('.idiom-substitution').val();
      indicateStatus(status, 'glyphicon-time', 'saving');
      var idiom_id = editor.attr('data-idiom-id');
      $.ajax({
        url: '/idioms/' + (idiom_id || ''),
        type: idiom_id ? 'PUT' : 'POST',
        data: editor.serialize(),
        success: function(idiomJson, textStatus, jqXHR) {
          indicateStatus(status, 'glyphicon-ok', 'saved');
          ensureEditorUpdateMode(editor, idiomJson.id);
          setRoleButtonLights();
        }
      });
    });
  }

  function makeIdiomDeleteButton(term) {
    var form = $('<form><button type=button id=delete-'+slugifyTerm(term)+' class="btn btn-default delete-idiom"><span class="glyphicon glyphicon-remove" aria-label="delete"></span></button></form>');
    form.find('button').click(function () {
      var container = form.closest('tr');
      var editor = container.find('.idiom-form');
      var idiom_id = editor.attr('data-idiom-id');
      if (!idiom_id) {
        container.remove();     // easy case - local only
      } else {
        // hard case - delete on server
        var status = editor.find('.idiom-ajax-status');
        indicateStatus(status, 'glyphicon-time', 'saving');
        $.ajax({url: '/idioms/' + idiom_id,
                type: 'DELETE',
                success: function() {
                  container.remove();
                  setRoleButtonLights();
                }});
      }
    });
    return form;
  }

  function ensureEditorUpdateMode(editor, idiom_id) {
    if (!editor || !idiom_id) {throw new Error("missing required arg");}
    editor.attr('data-idiom-id', idiom_id);
  }

  function indicateStatus(status, glyphiconClassName, ariaLabel) {
    status.empty().append('<span class="glyphicon ' + glyphiconClassName + '" aria-label="' + ariaLabel + '"></span>');
  }

  // build menus
  dancerMenuForChooser(chooser_dancers).forEach(function(dancer) {
    $('.new-dancers-idiom').append($('<option value="'+dancer+'">'+dancer+'</option>'));
  });
  moves().forEach(function(move) {
    $('.new-move-idiom').append($('<option value="'+move+'">'+move+'</option>'));
  });

  function rebuildIdiomsList(idiom_json_array) {
    var idiomsList = $('.idioms-list');
    idiomsList.empty();
    $.each(idiom_json_array, function(meh, idiom) {
      makeIdiomEditor(idiom.term, idiom.substitution, idiom.id);
    });
    setRoleButtonLights();
  }

  var buttonSubstitutions = $.map([['gent', 'gents', 'lady', 'ladies'],
                                   ['lark', 'larks', 'raven', 'ravens'],
                                   ['lead', 'leads', 'follow', 'follows']
                                  ],
                                  function(roleArr) {
                                    var gentlespoon = roleArr[0];
                                    var gentlespoons = roleArr[1];
                                    var ladle = roleArr[2];
                                    var ladles = roleArr[3];
                                    return {'gentlespoons': gentlespoons,
                                            'first gentlespoon': 'first '+gentlespoon,
                                            'second gentlespoon': 'second '+gentlespoon,
                                            'ladles': ladles,
                                            'first ladle': 'first '+ladle,
                                            'second ladle': 'second '+ladle};
                                  });

  // Walk the DOM and set role button lightedness appropriately. Profiled to take <= 5ms
  function setRoleButtonLights() {
    $.each(buttonSubstitutions, function(meh, bsub) {
      var $form = $('.'+bsub['gentlespoons']+'-'+bsub['ladles']);
      setRoleButtonLight($form, idiomEditorsMatcheButtonSubstitution(bsub));
    });
  }

  function setRoleButtonLight($form, bool) {
    $form.find('.btn').addClass(bool ? 'btn-primary' : 'btn-default').removeClass(bool ? 'btn-default' : 'btn-primary');
    $form.find('input[name=button_lite]').val(!bool);
  }

  function idiomEditorsMatcheButtonSubstitution(bsub) {
    var matches = 0;
    var bsub_length = 0;
    for (var term in bsub) {
      bsub_length++;
      var idioms_list = $('.idioms-list tr');
      for (var i=0; i < idioms_list.length; i++) { // can't iterate with .each() because I really want break and return
        var tr = $(idioms_list[i]);
        if (tr.find('.idiom-term').val() === term) {
          if (tr.find('.idiom-substitution').val() === bsub[term]) {
            matches++;
            break;
          } else {
            return false;
          }
        }
      }
    }
    return matches===bsub_length;
  }


  if ($('#idioms-init').length === 0) {
    throw new Error("Can't initialize page because can't find #idioms-init");
  }
  rebuildIdiomsList(JSON.parse($('#idioms-init').text()));

  // reset the whole dialect
  $('.restore-default-dialect-form').on('ajax:error', function() {
    $('.alert').html('Bummer! Error restoring default dialect.');
  }).on('ajax:success', function() {
    rebuildIdiomsList([]);
    $('.notice').html('Default dialect restored.');
  });

  // change roles with the click of a button
  $('.dialect-express-role-form').on('ajax:error', function() {
    $('.alert').html('Bummer! Error setting role.');
  }).on('ajax:success', function(e, idioms, status, xhr) {
    rebuildIdiomsList(idioms);
  });

  // change gyre with the click of a button
  $('.dialect-express-gyre-form').on('ajax:error', function() {
    $('.alert').html('Bummer! Error setting gyre.');
  }).on('ajax:success', function(e, idioms, status, xhr) {
    rebuildIdiomsList(idioms);
  });
});
