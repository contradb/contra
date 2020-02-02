import * as React from "react"
import { useState } from "react"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"

const match_nothing: Filter = ["or"] //  kinda non-obvious how to express tihs in filters, eh?

export const AdvancedSearch = () => {
  const [choreographer, setChoreographer] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const ezFilter: Filter = ["and"]
  choreographer && ezFilter.push(["choreographer", choreographer])
  if (verifiedChecked) {
    if (notVerifiedChecked) {
      // do nothing
    } else {
      ezFilter.push(["compare", ["constant", 0], "<", ["tag", "verified"]])
    }
  } else {
    if (notVerifiedChecked) {
      ezFilter.push(["compare", ["constant", 0], "=", ["tag", "verified"]])
    } else {
      ezFilter.push(match_nothing)
    }
  }

  !notVerifiedChecked &&
    ezFilter.push(["compare", ["constant", 0], "<", ["tag", "verified"]])
  const filter = ["if", ezFilter, ["figure", "*"]]

  return (
    <div>
      <label>
        Choreographer:
        <input
          type="text"
          className="ez-choreographer-filter form-control"
          value={choreographer}
          onChange={e => setChoreographer(e.target.value)}
        />
      </label>
      <br />
      <EzCheckboxFilter
        checked={verifiedChecked}
        setChecked={setVerifiedChecked}
        name="verified"
      />
      <EzCheckboxFilter
        checked={notVerifiedChecked}
        setChecked={setNotVerifiedChecked}
        name="not verified"
      />
      <br />
      <br />
      <br />
      <DanceTable filter={filter} />
    </div>
  )
}
export default AdvancedSearch
