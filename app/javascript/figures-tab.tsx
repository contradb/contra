import React, { Dispatch } from "react"
import { SearchEx } from "./search-ex"

const makeOpOption = (op: string, i: number) => {
  if (op === "____")
    return (
      <option key={i} style={{ backgroundColor: "white" }} disabled>
        ————————
      </option>
    )
  else
    return (
      <option key={i} value={op}>
        {op.replace(/-/, " ")}
      </option>
    )
}

const nonNumericOpOptions = [
  "figure",
  "or",
  "and",
  "then",
  "no",
  "not",
  "all",
  "progress with",
  "____",
  "&",
  "progression",
  "compare",
  "formation",
].map(makeOpOption)

const numericOpOptions = ["constant", "tag", "count-matches"].map(makeOpOption)

export const FiguresTab = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
}) => (
  <>
    Coming Soon!
    <div className="search-ex">
      <select
        value={searchEx.op()}
        onChange={e => {
          const op = e.target.value
          setSearchEx(searchEx.castTo(op))
        }}
        className="form-control"
      >
        {searchEx.isNumeric() ? numericOpOptions : nonNumericOpOptions}
      </select>
    </div>
    {JSON.stringify(searchEx.toLisp())}
  </>
)
export default FiguresTab
