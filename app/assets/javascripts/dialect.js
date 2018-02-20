$(document).ready(function() {
  var newIdiomTerm = $('#new-idiom-term');

  if (0 === newIdiomTerm.length) {
    return;                     // don't do any of this stuff if we're not on a page with a query.
  }

  var idioms = [];                // TODO: load from DOM

  var newIdiomButton = $('.show-new-idiom-dialog');

  newIdiomTerm.change(function() {
    newIdiomButton.prop('disabled', !$(this).val());
  });

  moves().forEach(function(move) {
    newIdiomTerm.append($('<option value="'+move+'">'+move+'</option>'));
  });
});
