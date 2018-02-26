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

// TODO delete this dross
// $(document).ready(function() {
//   console.log('sporks');
//   $('*').on('ajax:beforeSend', function(event, xhr, status, error) {
//     foobar = true;
    
//     alert('never see this');
//   });
//   console.log('knaves');
//   $('button').on('ajax:success', function() {
//     console.log('hola');
//     alert('hola');
//     return true;
//   });
//   $('button').on('ajax:error', function() {
//     console.log('buuurp');
//     alert('burrrp');
//     return true;
//   });
//   $('form').on('ajax:success', function() {
//     console.log('hola');
//     alert('hola');
//     return true;
//   });
//   $('form').on('ajax:error', function() {
//     console.log('buuurp');
//     alert('burrrp');
//     return true;
//   });
// });
