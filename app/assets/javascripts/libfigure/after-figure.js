//     _    _____ _____ _____ ____       _____ ___ ____ _   _ ____  _____    _     
//    / \  |  ___|_   _| ____|  _ \     |  ___|_ _/ ___| | | |  _ \| ____|  (_)___ 
//   / _ \ | |_    | | |  _| | |_) |____| |_   | | |  _| | | | |_) |  _|    | / __|
//  / ___ \|  _|   | | | |___|  _ <_____|  _|  | | |_| | |_| |  _ <| |___ _ | \__ \
// /_/   \_\_|     |_| |_____|_| \_\    |_|   |___\____|\___/|_| \_\_____(_)/ |___/
//                                                                        |__/     


// all moves with a balance are related to the move 'balance'
moves().forEach(function (move) {
  parameters(move).forEach(function(param) {
    if (param.name === param_balance_true.name) {
      defineRelatedMove2Way(move, 'balance');
    }
  });
});
