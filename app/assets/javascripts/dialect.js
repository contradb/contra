$(document).ready(function() {
  var newIdiomTerm = $('#new-idiom-term');

  if (0 === newIdiomTerm.length) {
    return;                     // don't do any of this stuff if we're not on a page with a query.
  }

  var idioms = [];                // TODO: load from DOM

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

  var newIdiomTermMovesOptGroup = newIdiomTerm.children('optgroup[label=moves]');
  moves().forEach(function(move) {
    newIdiomTermMovesOptGroup.append($('<option value="'+move+'">'+move+'</option>'));
  });
  var newIdiomTermDancersOptGroup = newIdiomTerm.children('optgroup[label=dancers]');
  dancerMenuForChooser(chooser_dancers).forEach(function(dancer) {
    newIdiomTermDancersOptGroup.append($('<option value="'+dancer+'">'+dancer+'</option>'));
  });
});
