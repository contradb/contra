import * as React from "react"
import { useState } from "react"
import DanceTable from "./dance-table"
import Filter from "./filter"

export const AdvancedSearch = () => {
  const [choreographer, setChoreographer] = useState("")
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const ezFilter: Filter = ["and"]
  choreographer && ezFilter.push(["choreographer", choreographer])
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
      <label>
        <input
          type="checkbox"
          checked={notVerifiedChecked}
          onChange={e => setNotVerifiedChecked(e.target.checked)}
        />
        &nbsp; not verified
      </label>
      <br />
      <br />
      <br />
      <DanceTable filter={filter} />
    </div>
  )
}
export default AdvancedSearch
