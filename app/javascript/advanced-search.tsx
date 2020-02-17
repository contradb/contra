import * as React from "react"
import { useState } from "react"
import Cookie from "js-cookie"
import DanceTable from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"
import SearchTabs from "./search-tabs"
import {
  getVerifiedFilter,
  getPublishFilter,
  getFormationFilters,
} from "./ez-query-helpers"

export const AdvancedSearch = (): JSX.Element => {
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"
  const [choreographer, setChoreographer] = useState("")
  const [hook, setHook] = useState("")
  const [verifiedChecked, setVerifiedChecked] = useState(true)
  const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)
  const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)
  const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)
  const [publishAll, setPublishAll] = useState(true)
  const [publishSketchbook, setPublishSketchbook] = useState(false)
  const [publishOff, setPublishOff] = useState(false)
  const [enteredByMe, setEnteredByMe] = useState(false)
  const [improper, setImproper] = useState(true)
  const [becket, setBecket] = useState(true)
  const [proper, setProper] = useState(true)
  const [otherFormation, setOtherFormation] = useState(true)
  const verifiedFilter: Filter = getVerifiedFilter({
    v: verifiedChecked,
    nv: notVerifiedChecked,
    vbm: verifiedCheckedByMe,
    nvbm: notVerifiedCheckedByMe,
  })
  const choreographerFilters: Filter[] = choreographer
    ? [["choreographer", choreographer]]
    : []
  const hookFilters: Filter[] = hook ? [["hook", hook]] : []
  const publishFilter: Filter = getPublishFilter({
    all: publishAll,
    sketchbook: publishSketchbook,
    off: publishOff,
    byMe: enteredByMe,
  })
  const formationFilters: Filter[] = getFormationFilters({
    improper,
    becket,
    proper,
    otherFormation,
  })
  const ezFilter: Filter = [
    "and",
    verifiedFilter,
    publishFilter,
    ...[...choreographerFilters, ...hookFilters, ...formationFilters], // ts being grumpy!
  ]
  const grandFilter: Filter = ["if", ezFilter, ["figure", "*"]]

  return (
    <div>
      <SearchTabs
        initialIndex={2}
        tabs={[
          {
            name: "filters",
            body: (
              <div>
                <h4>Choreographer:</h4>
                <input
                  type="text"
                  className="ez-choreographer-filter form-control"
                  style={{ maxWidth: "15em" }}
                  value={choreographer}
                  onChange={e => setChoreographer(e.target.value)}
                  title="the person who wrote the dance - optional"
                />
                <br />
                <h4>Hook:</h4>
                <input
                  type="text"
                  className="ez-hook-filter form-control"
                  style={{ maxWidth: "15em" }}
                  value={hook}
                  onChange={e => setHook(e.target.value)}
                  title="search for words in reason the dance is interesting - optional"
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
                <h4>Formation:</h4>
                <EzCheckboxFilter
                  checked={improper}
                  setChecked={setImproper}
                  name="improper"
                  title="search among duple improper contras"
                />
                <EzCheckboxFilter
                  checked={becket}
                  setChecked={setBecket}
                  name="becket"
                  title="search among Becket contras"
                />
                <EzCheckboxFilter
                  checked={proper}
                  setChecked={setProper}
                  name="proper"
                  title="search among duple proper contras"
                />
                <EzCheckboxFilter
                  checked={otherFormation}
                  setChecked={setOtherFormation}
                  name="everything else"
                  title="search among all the other formations"
                />
              </div>
            ),
          },
          { name: "query", body: <div>Coming Soon!</div> },
          { name: "results", body: <DanceTable filter={grandFilter} /> },
          { name: "program", body: <div>Coming Eventually!</div> },
        ]}
      />
    </div>
  )
}

export default AdvancedSearch
