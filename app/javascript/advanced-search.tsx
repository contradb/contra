import * as React from "react"
import { useState } from "react"
import Cookie from "js-cookie"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"

const matchNothing: Filter = ["or"] //  kinda non-obvious how to express tihs in filters, eh?
const matchEverything: Filter = ["and"] //  kinda non-obvious how to express tihs in filters, eh?

export const AdvancedSearch = () => {
  const [choreographer, setChoreographer] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)
  const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)
  const vFilter: Filter = verifiedFilter({
    v: verifiedChecked,
    nv: notVerifiedChecked,
    vbm: verifiedCheckedByMe,
    nvbm: notVerifiedCheckedByMe,
  })
  const ezFilter: Filter = ["and", vFilter]
  choreographer && ezFilter.push(["choreographer", choreographer])
  const filter: Filter = ["if", ezFilter, ["figure", "*"]]

  return (
    <div>
      <h4>Choreographer:</h4>
      <input
        type="text"
        className="ez-choreographer-filter form-control"
        value={choreographer}
        onChange={e => setChoreographer(e.target.value)}
      />
      <br />
      <br />
      <h4>Verified:</h4>
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
      <EzCheckboxFilter
        checked={verifiedCheckedByMe}
        setChecked={setVerifiedCheckedByMe}
        name="verified by me"
      />
      <EzCheckboxFilter
        checked={notVerifiedCheckedByMe}
        setChecked={setNotVerifiedCheckedByMe}
        name="not verified by me"
      />
      <br />
      <br />
      <br />
      <DanceTable filter={filter} />
    </div>
  )
}

const verifiedFilter = ({
  v,
  nv,
  vbm,
  nvbm,
}: {
  v: boolean
  nv: boolean
  vbm: boolean
  nvbm: boolean
}): Filter => {
  const r: Filter = ["or"]
  if (v) {
    if (nv) {
      return matchEverything
    } else {
      r.push(["compare", ["constant", 0], "<", ["tag", "verified"]])
    }
  } else {
    if (nv) {
      r.push(["compare", ["constant", 0], "=", ["tag", "verified"]])
    } else {
      // do nothing
    }
  }
  if (vbm) {
    if (nvbm) {
      return matchEverything
    } else {
      v || r.push(["my tag", "verified"])
    }
  } else {
    if (nvbm) {
      nv || r.push(["no", ["my tag", "verified"]])
    } else {
      // do nothing
    }
  }
  return r
}

export default AdvancedSearch
