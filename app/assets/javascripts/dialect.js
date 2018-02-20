$(document).ready(function() {
  var newIdiomTerm = $('#new-idiom-term');

  if (0 === newIdiomTerm.length) {
    return;                     // don't do any of this stuff if we're not on a page with a query.
  }

  var idioms = [];                // TODO: load from DOM

  var newIdiomButton = $('.show-new-idiom-dialog');

  newIdiomButton.click(function () {
    // this just sets the dialog title.
    $('#new-idiom-modal .modal-title').text("Substitute for “" + newIdiomTerm.val() + "”");
    // The actual heavy lifting of the dialog is done by the jquery dialog plugin and
    // data-attributes, which we fall through to by not preventing default here.
  });

  newIdiomTerm.change(function() {
    newIdiomButton.prop('disabled', !$(this).val());
  });

  moves().forEach(function(move) {
    newIdiomTerm.append($('<option value="'+move+'">'+move+'</option>'));
  });
});
