import React, { Dispatch } from "react"
import { SearchEx } from "./search-ex"
import SearchExEditor from "./search-ex-editor"

const strangely_spaced_out_json_stringify = (thing: any): string => {
  if (Array.isArray(thing)) {
    return (
      "[ " + thing.map(strangely_spaced_out_json_stringify).join(", ") + " ]"
    )
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
}) => (
  <>
    <SearchExEditor
      searchEx={searchEx}
      setSearchEx={setSearchEx}
      removeSearchEx={null}
      id="search-ex-root"
    />
    <div id="debug-lisp" className="hidden">
      {strangely_spaced_out_json_stringify(searchEx.toLisp())}
    </div>
  </>
)
export default FiguresTab
