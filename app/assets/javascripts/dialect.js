$(document).ready(function() {
  $('.new-dancers-idiom').change(function(e) {
    console.log($(this).val());
  });

  // Processing by IdiomsController#create as HTML
  //   Parameters: {"utf8"=>"✓", "authenticity_token"=>"jFPa8/dB516ypB7SjFiiQyMJPkDiW3xIXiMjCvI0TVCr2H6yKkKRhb3f1dWKfWBDwat7nXCm1bpNc9DdpEBnbA==", "idiom_idiom"=>{"term"=>"gyre", "substitution"=>"foo"}, "commit"=>"Save"}


  $('.new-move-idiom').change(function(e) {
    var term = $(this).val();
    var authenticityToken = $('#authenticity-token-incubator input[name=authenticity_token]').val();
    var presumed_server_substitution = term;
    var editor =
          $('<form action="/idioms" accept-charset="UTF-8" method="post">' +
            '  <input name="utf8" value="✓" type="hidden">' +
            '  <input name="idiom_idiom[term]" value="' + term + '" type="hidden">' +
            '  <input name="authenticity_token" value="' + authenticityToken +'" type="hidden">' +
                 term +
            ' → <input name="idiom_idiom[substitution]" type=text class="idiom-substitution"></label> <span class="idiom-ajax-progress"></span></form>');
    $('.idioms-list').append(editor);
    var progress = editor.find('.idiom-ajax-progress');
    editor.find('.idiom-substitution').val(presumed_server_substitution);
    editor.find('.idiom-substitution').on('input', function () {
      if (editor.find('.idiom-substitution').val() !== presumed_server_substitution) {
        progress.empty().append('<span class="glyphicon glyphicon-pencil" aria-label="changed"></span>');
      } else {
        progress.empty().append('<span class="glyphicon glyphicon-ok" aria-label="saved"></span>');
      }
    });
    editor.submit(function(event) {
      event.preventDefault();
      presumed_server_substitution = editor.find('.idiom-substitution').val();
      progress.empty().append('<span class="glyphicon glyphicon-arrow-up" aria-label="saving..."></span>');
      $.post(editor.attr('action'), editor.serialize()).done(function() {
        progress.empty().append('<span class="glyphicon glyphicon-ok" aria-label="saved"></span>');
      });
    });
  });

  // build menus
  dancerMenuForChooser(chooser_dancers).forEach(function(dancer) {
    $('.new-dancers-idiom').append($('<option value="'+dancer+'">'+dancer+'</option>'));
  });
  moves().forEach(function(move) {
    $('.new-move-idiom').append($('<option value="'+move+'">'+move+'</option>'));
  });
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
    idiomsList.append("<div>" + idiom.term + " → "+ idiom.substitution + "</div>");
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

$(document).ready(function() {
  if ($('.idioms-list').length <= 0) {return;} // this code is about maintaining .idioms-list

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
