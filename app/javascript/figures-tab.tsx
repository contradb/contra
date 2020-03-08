import React, { Dispatch } from "react"
import { SearchEx } from "./search-ex"
import SearchExEditor from "./search-ex-editor"

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
    {JSON.stringify(searchEx.toLisp())}
  </>
)
export default FiguresTab
