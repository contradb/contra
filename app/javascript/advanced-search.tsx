import * as React from "react"
import { useState } from "react"
import Cookie from "js-cookie"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"

const matchNothing: Filter = ["or"] //  kinda non-obvious how to express tihs in filters, eh?
const matchEverything: Filter = ["and"] //  kinda non-obvious how to express tihs in filters, eh?

export const AdvancedSearch = () => {
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const [choreographer, setChoreographer] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)
  const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)
  const [sketchbooks, setSketchbooks] = useState(false)
  const verifiedFilter: Filter = getVerifiedFilter({
    v: verifiedChecked,
    nv: notVerifiedChecked,
    vbm: verifiedCheckedByMe,
    nvbm: notVerifiedCheckedByMe,
  })
  const choreographerFilters: Filter[] = choreographer
    ? [["choreographer", choreographer]]
    : []
  const publishFilter: Filter = getPublishFilter({
    all: true,
    sketchbook: sketchbooks,
    off: false,
  })
  const ezFilter: Filter = [
    "and",
    verifiedFilter,
    publishFilter,
    ...choreographerFilters,
  ]
  const grandFilter: Filter = ["if", ezFilter, ["figure", "*"]]

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
        disabledReason={signedIn ? null : "must be logged in"}
        name="verified by me"
      />
      <EzCheckboxFilter
        checked={notVerifiedCheckedByMe}
        setChecked={setNotVerifiedCheckedByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="not verified by me"
      />
      <br />
      <br />
      <h4>Shared:</h4>
      <EzCheckboxFilter
        checked={sketchbooks}
        setChecked={setSketchbooks}
        name="sketchbooks"
      />
      <br />
      <br />
      <br />
      <DanceTable filter={grandFilter} />
    </div>
  )
}

export const getVerifiedFilter = ({
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
      nvbm || r.push(["compare", ["constant", 0], "=", ["tag", "verified"]])
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
      r.push(["no", ["my tag", "verified"]])
    } else {
      // do nothing
    }
  }
  return r
}

export const getPublishFilter = ({
  all,
  sketchbook,
  off,
}: {
  all: boolean
  sketchbook: boolean
  off: boolean
}): Filter => {
  const allFilters: Filter[] = all ? [["publish", "all"]] : []
  const offFilters: Filter[] = off ? [["publish", "off"]] : []
  const sketchbookFilters: Filter[] = sketchbook
    ? [["publish", "sketchbook"]]
    : []
  const filters: Filter[] = [...allFilters, ...sketchbookFilters, ...offFilters]
  switch (filters.length) {
    case 0:
      return matchNothing
    case 1:
      return filters[0]
    case 2:
      return ["or", ...filters]
    case 3:
      return matchEverything
    default:
      throw new Error("fell through case statement")
  }
}

export default AdvancedSearch
