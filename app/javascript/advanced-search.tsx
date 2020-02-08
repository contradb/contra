import * as React from "react"
import { useState } from "react"
import Cookie from "js-cookie"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"
import { getVerifiedFilter, getPublishFilter } from "./ez-query-helpers"

export const AdvancedSearch = (): JSX.Element => {
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"
  const [choreographer, setChoreographer] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)
  const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)
  const [publishAll, setPublishAll] = useState(true)
  const [publishSketchbook, setPublishSketchbook] = useState(false)
  const [publishOff, setPublishOff] = useState(false)
  const [enteredByMe, setEnteredByMe] = useState(false)
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
    all: publishAll,
    sketchbook: publishSketchbook,
    off: publishOff,
    byMe: enteredByMe,
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
      <br />
      <h4>Choreographer:</h4>
      <input
        type="text"
        className="ez-choreographer-filter form-control"
        style={{ maxWidth: "15em" }}
        value={choreographer}
        onChange={e => setChoreographer(e.target.value)}
        title="optional"
      />
      <br />
      <br />
      <h4>Verified:</h4>
      <EzCheckboxFilter
        checked={verifiedChecked}
        setChecked={setVerifiedChecked}
        name="verified"
        title="search among dances that have been called"
      />
      <EzCheckboxFilter
        checked={notVerifiedChecked}
        setChecked={setNotVerifiedChecked}
        name="not verified"
        title="search among dances that have not been called "
      />
      <EzCheckboxFilter
        checked={verifiedCheckedByMe}
        setChecked={setVerifiedCheckedByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="verified by me"
        title="search among dances that you have called"
      />
      <EzCheckboxFilter
        checked={notVerifiedCheckedByMe}
        setChecked={setNotVerifiedCheckedByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="not verified by me"
        title="search among dances you have not called"
      />
      <br />
      <br />
      <h4>Shared:</h4>
      <EzCheckboxFilter
        checked={publishAll}
        setChecked={setPublishAll}
        name="shared"
        title="search among dances shared to all"
      />
      <EzCheckboxFilter
        checked={publishSketchbook}
        setChecked={setPublishSketchbook}
        name="sketchbooks"
        title="search among dances shared to sketchbooks - the person entering them does not think they should be called"
      />
      {isAdmin && (
        <EzCheckboxFilter
          checked={publishOff}
          setChecked={setPublishOff}
          name="private"
          title="search among dances that have sharing off"
        />
      )}
      <EzCheckboxFilter
        checked={enteredByMe}
        setChecked={setEnteredByMe}
        disabledReason={signedIn ? null : "must be logged in"}
        name="entered by me"
        title="search among dances you have entered"
      />
      <br />
      <br />
      <br />
      <DanceTable filter={grandFilter} />
    </div>
  )
}

export default AdvancedSearch
