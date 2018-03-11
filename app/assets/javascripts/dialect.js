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
    var editor =
          $('<form action="/idioms" accept-charset="UTF-8" method="post">' +
            '  <input name="utf8" value="✓" type="hidden">' +
            '  <input name="idiom_idiom[term]" value="' + term + '" type="hidden">' +
            '  <input name="authenticity_token" value="' + authenticityToken +'" type="hidden">' +
            term +
            ' → <input name="idiom_idiom[substitution]" type=text class="idiom-substitution" id="' + slugifyTerm(term) + '-substitution"></label> ' +
            '  <span class="idiom-ajax-status"></span>'+
            '</form>');
    var status = editor.find('.idiom-ajax-status');
    indicateStatus(status, 'glyphicon-ok', 'saved');
    if (opt_id) { ensureUpdateEditor(editor, opt_id); }
    $('.idioms-list').append(editor);
    editor.find('.idiom-substitution').val(presumed_server_substitution);
    editor.find('.idiom-substitution').on('input', function () {
      if (editor.find('.idiom-substitution').val() !== presumed_server_substitution) {
        indicateStatus(status, 'glyphicon-pencil', 'unsaved');
      } else {
        indicateStatus(status, 'glyphicon-ok', 'saved');
      }
    });
    editor.submit(function(event) {
      event.preventDefault();
      presumed_server_substitution = editor.find('.idiom-substitution').val();
      indicateStatus(status, 'glyphicon-arrow-up', 'saving');
      $.ajax({
        url: editor.attr('action'),
        type: editor.attr('method'),
        data: editor.serialize(),
        success: function(idiomJson, textStatus, jqXHR) {
          indicateStatus(status, 'glyphicon-ok', 'saved');
          ensureUpdateEditor(editor, idiomJson.id);
        }
      });
    });
  }

  function ensureUpdateEditor(editor, idiom_id) {
    if (!editor || !idiom_id) {throw new Error("missing required arg");}
    var is_create_editor = 0 === editor.find('.idiom-id').length;
    if (is_create_editor) {
      editor.attr('action','/idioms/' + idiom_id).attr('method', 'put');
    }
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

  function rebuildIdiomsList(idiom_json_array) {
    var idiomsList = $('.idioms-list');
    idiomsList.empty();
    $.each(idiom_json_array, function(meh, idiom) {
      makeIdiomEditor(idiom.term, idiom.substitution, idiom.id);
    });
    $.each(buttonSubstitutions, function(meh, bsub) {
      var $form = $('.'+bsub['gentlespoons']+'-'+bsub['ladles']);
      setButtonLight($form, idiomJsonMatchesButtonSubstitution(idiom_json_array, bsub));
    });
  }

  function setButtonLight($form, bool) {
    $form.find('.btn').addClass(bool ? 'btn-primary' : 'btn-default').removeClass(bool ? 'btn-default' : 'btn-primary');
    $form.find('input[name=lit]').val(!bool);
  }

  function idiomJsonMatchesButtonSubstitution(idioms, bsub) {
    var matches = 0;
    var bsub_length = 0;
    for (var term in bsub) {
      bsub_length++;
      for (var i=0; i<idioms.length; i++) {
        var idiom = idioms[i];
        if (idiom.term === term) {
          if (idiom.substitution === bsub[term]) {
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
  $('.one-click-role-form').on('ajax:error', function() {
    $('.alert').html('Bummer! Error setting role.');
  }).on('ajax:success', function(e, idioms, status, xhr) {
    rebuildIdiomsList(idioms);
  });
});
