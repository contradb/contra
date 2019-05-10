// repackage exports in a single file, so that LibFigure consumers
// don't have to worry about what specific file a variable is defined
// in.

import {param} from './param.js';
import {chooser} from './chooser.js';
import {moves, moveTermsAndSubstitutionsForSelectMenu, parameters} from './define-figure.js';
import {} from './figure.js';       // for side effect!
import {} from './after-figure.js'; // for ... side effect?
import {} from './dance.js';        // ?? for side effect??

export default {
  param,
  chooser,
  moves,
  moveTermsAndSubstitutionsForSelectMenu,
  parameters
};
