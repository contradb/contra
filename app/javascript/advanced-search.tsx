import * as React from "react"
import { useState } from "react"
import Cookie from "js-cookie"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"
import { getVerifiedFilter, getPublishFilter } from "./ez-query-helpers"

export const AdvancedSearch = () => {
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"
  const [choreographer, setChoreographer] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)
  const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)
  const [publishAll, setPublishAll] = useState(true)
  const [publishSketchBook, setPublishSketchbook] = useState(false)
  const [publishOff, setPublishOff] = useState(false)
  const [byMe, setByMe] = useState(false)
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
    sketchbook: publishSketchBook,
    off: publishOff,
    byMe,
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
        checked={byMe}
        setChecked={setByMe}
        name="anything by me"
      />
      <EzCheckboxFilter
        checked={publishAll}
        setChecked={setPublishAll}
        name="shared"
      />
      <EzCheckboxFilter
        checked={publishSketchBook}
        setChecked={setPublishSketchbook}
        name="sketchbooks"
      />
      {isAdmin && (
        <EzCheckboxFilter
          checked={publishOff}
          setChecked={setPublishOff}
          name="private"
        />
      )}
      <br />
      <br />
      <br />
      <DanceTable filter={grandFilter} />
    </div>
  )
}

export default AdvancedSearch
