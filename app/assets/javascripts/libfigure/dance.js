
var invertPairHash =
    {"ladles": "gentlespoons"
    ,"gentlespoons": "ladles"
    ,"ones": "twos"
    ,"twos": "ones"
    ,"first corners": "second corners"
    ,"second corners": "first corners"
    };
// If this names 2 dancers, this returns the names for the other 2 dancers
// it's sketchy, because it assumes 4 dancers, so only use it in contra moves
function invertPair(whostr, falsey_ok) {
  if (falsey_ok && !whostr) {
    return whostr;
  } else {
    return invertPairHash[whostr] || (throw_up("bogus parameter to invertPairHash: "+ whostr));
  }
}

function labelForBeats(beats) {
    if ((beats%16) == 0)
        switch (beats/16) {
        case 0: return "A1";
        case 1: return "A2";
        case 2: return "B1";
        case 3: return "B2";
        case 4: return "C1";
        case 5: return "C2";
        case 6: return "D1";
        case 7: return "D2";
    }
    return "";
}

