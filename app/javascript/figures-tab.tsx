import React from "react"
import { SearchEx } from "./search-ex"
import SearchExEditor from "./search-ex-editor"

const strangelySpacedOutJsonStringify = (thing: any): string => {
  if (Array.isArray(thing)) {
    return "[ " + thing.map(strangelySpacedOutJsonStringify).join(", ") + " ]"
  } else {
    return JSON.stringify(thing)
  }
}

export const FiguresTab = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
}): JSX.Element => (
  <>
    <SearchExEditor
      searchEx={searchEx}
      setSearchEx={setSearchEx}
      removeSearchEx={null}
      id="search-ex-root"
    />
    <div id="debug-lisp" className="hidden">
      {strangelySpacedOutJsonStringify(searchEx.toLisp())}
    </div>
  </>
)
export default FiguresTab
