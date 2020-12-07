import React from "react"
import { SearchEx } from "./search-ex"
import SearchExEditor from "./search-ex-editor"
import ClearTabButton from "./clear-tab-button"

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
  isClear,
  clear,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
  isClear: boolean
  clear: () => void
}): JSX.Element => (
  <>
    <div className="text-align-center">
      <ClearTabButton name="Search" clear={clear} isClear={isClear} />
    </div>
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
