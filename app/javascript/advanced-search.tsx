import * as React from "react"
import { useState } from "react"
import DanceTable from "./dance-table"

export const AdvancedSearch = () => {
  const [choreographer, setChoreographer] = useState("")
  const filter = [
    "if",
    [
      "and",
      ["choreographer", choreographer],
      ["compare", ["constant", 0], "<", ["tag", "verified"]],
    ],
    ["figure", "*"],
  ]

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
      <br />
      <br />
      <DanceTable filter={filter} />
    </div>
  )
}
export default AdvancedSearch
