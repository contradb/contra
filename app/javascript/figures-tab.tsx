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
    Coming Soon!
    <SearchExEditor searchEx={searchEx} setSearchEx={setSearchEx} />
    state.lisp: {strangely_spaced_out_json_stringify(searchEx.toLisp())}
  </>
)
export default FiguresTab
