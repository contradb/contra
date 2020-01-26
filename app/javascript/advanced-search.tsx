import * as React from "react"
import DanceTable from "./dance-table"

export const AdvancedSearch = () => (
  <div>
    <label>
      Choreographer:
      <input type="text" className="ez-choreographer-filter form-control" />
    </label>
    <br />
    <br />
    <br />
    <DanceTable />
  </div>
)

export default AdvancedSearch
