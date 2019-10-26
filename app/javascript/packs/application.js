import "core-js/stable";
import "regenerator-runtime/runtime";

import {foo} from "../foo.ts"

const f = x => x+" robot";

console.log(foo("Hello space banana", "robot"))
