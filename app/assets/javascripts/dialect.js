$(document).ready(function() {
  var newIdiomTerm = $('#new-idiom-term');

  if (0 === newIdiomTerm.length) {return;} // don't do any of this stuff if we're not on a page with a query.

  var newIdiomButton = $('.show-new-idiom-dialog');

  newIdiomButton.click(function () {
    var term = newIdiomTerm.val();
    $('#new-idiom-modal .modal-title').text("Substitute for “" + term + "”");
    $('#new-idiom-modal .modal-term').val(term);
    // The actual posting of the dialog is done by the jquery dialog plugin and
    // data-attributes, which we fall through to by not preventing default here.
  });

  newIdiomTerm.change(function() {
    newIdiomButton.prop('disabled', !$(this).val());
  });

  // build menus
  var newIdiomTermMovesOptGroup = newIdiomTerm.children('optgroup[label=moves]');
  moves().forEach(function(move) {
    newIdiomTermMovesOptGroup.append($('<option value="'+move+'">'+move+'</option>'));
  });
  var newIdiomTermDancersOptGroup = newIdiomTerm.children('optgroup[label=dancers]');
  dancerMenuForChooser(chooser_dancers).forEach(function(dancer) {
    newIdiomTermDancersOptGroup.append($('<option value="'+dancer+'">'+dancer+'</option>'));
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

  rebuildIdiomsList(JSON.parse($('.idioms-init').text()));

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
