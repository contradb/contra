import * as React from "react"
import { useState, useCallback } from "react"
import Cookie from "js-cookie"
import {
  DanceTable,
  FetchDataFn,
  sortByParam,
  SearchDancesDanceJson,
  SearchDancesJson,
} from "./dance-table"
import EzCheckboxFilter from "./ez-checkbox-filter"
import Filter from "./filter"
import useFilter from "use-filter"
import SearchTabs from "./search-tabs"

export const AdvancedSearch = (): JSX.Element => {
  const [signedIn] = useState(() => Cookie.get("signed_in"))
  const isAdmin = signedIn === "admin"

  const [searchDancesJson, setSearchDancesJson] = useState({
    dances: [] as SearchDancesDanceJson[],
    numberSearched: 0,
    numberMatching: 0,
  })

  const [loading, setLoading] = React.useState(false)
  const [pageCount, setPageCount] = React.useState(0)

  const fetchDataFn: FetchDataFn = useCallback(
    ({ pageSize, pageIndex, sortBy, filter }) => {
      setLoading(true)
      async function fetchData1(): Promise<void> {
        const offset = pageIndex * pageSize
        const sort = sortByParam(sortBy)
        const url = "/api/v1/dances"
        const headers = { "Content-type": "application/json" }
        const body = JSON.stringify({
          count: pageSize,
          offset: offset,
          sort_by: sort,
          filter: filter,
        })
        const response = await fetch(url, { method: "POST", headers, body })
        const json: SearchDancesJson = await response.json()
        setSearchDancesJson(json)
        setPageCount(Math.ceil(json.numberMatching / pageSize))
        setLoading(false)
      }
      fetchData1()
      // maybe return in-use-ness to prevent a memory leak here?
    },
    []
  )
  const { filter, dictionary } = useFilter()
  const d: any = dictionary
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
                  value={d.choreographer}
                  onChange={e => d.setChoreographer(e.target.value)}
                  title="the person who wrote the dance - optional"
                />
                <br />
                <h4>Hook:</h4>
                <input
                  type="text"
                  className="ez-hook-filter form-control"
                  style={{ maxWidth: "15em" }}
                  value={d.hook}
                  onChange={e => d.setHook(e.target.value)}
                  title="search for words in reason the dance is interesting - optional"
                />
                <br />
                <br />
                <h4>Verified:</h4>
                <EzCheckboxFilter
                  checked={d.verifiedChecked}
                  setChecked={d.setVerifiedChecked}
                  name="verified"
                  title="search among dances that have been called"
                />
                <EzCheckboxFilter
                  checked={d.notVerifiedChecked}
                  setChecked={d.setNotVerifiedChecked}
                  name="not verified"
                  title="search among dances that have not been called "
                />
                <EzCheckboxFilter
                  checked={d.verifiedCheckedByMe}
                  setChecked={d.setVerifiedCheckedByMe}
                  disabledReason={signedIn ? null : "must be logged in"}
                  name="verified by me"
                  title="search among dances that you have called"
                />
                <EzCheckboxFilter
                  checked={d.notVerifiedCheckedByMe}
                  setChecked={d.setNotVerifiedCheckedByMe}
                  disabledReason={signedIn ? null : "must be logged in"}
                  name="not verified by me"
                  title="search among dances you have not called"
                />
                <br />
                <br />
                <h4>Shared:</h4>
                <EzCheckboxFilter
                  checked={d.publishAll}
                  setChecked={d.setPublishAll}
                  name="shared"
                  title="search among dances shared to all"
                />
                <EzCheckboxFilter
                  checked={d.publishSketchbook}
                  setChecked={d.setPublishSketchbook}
                  name="sketchbooks"
                  title="search among dances shared to sketchbooks - the person entering them does not think they should be called"
                />
                {isAdmin && (
                  <EzCheckboxFilter
                    checked={d.publishOff}
                    setChecked={d.setPublishOff}
                    name="private"
                    title="search among dances that have sharing off"
                  />
                )}
                <EzCheckboxFilter
                  checked={d.enteredByMe}
                  setChecked={d.setEnteredByMe}
                  disabledReason={signedIn ? null : "must be logged in"}
                  name="entered by me"
                  title="search among dances you have entered"
                />
                <br />
                <br />
                <h4>Formation:</h4>
                <EzCheckboxFilter
                  checked={d.improper}
                  setChecked={d.setImproper}
                  name="improper"
                  title="search among duple improper contras"
                />
                <EzCheckboxFilter
                  checked={d.becket}
                  setChecked={d.setBecket}
                  name="becket"
                  title="search among Becket contras"
                />
                <EzCheckboxFilter
                  checked={d.proper}
                  setChecked={d.setProper}
                  name="proper"
                  title="search among duple proper contras"
                />
                <EzCheckboxFilter
                  checked={d.otherFormation}
                  setChecked={d.setOtherFormation}
                  name="everything else"
                  title="search among all the other formations"
                />
              </div>
            ),
          },
          { name: "figures", body: <div>Coming Soon!</div> },
          {
            name: `${searchDancesJson.numberMatching} dance${
              1 === searchDancesJson.numberMatching ? "" : "s"
            }`,
            loading: loading,
            body: (
              <>
                {loading && (
                  <div className="floating-loading-indicator">loading...</div>
                )}

                <DanceTable
                  filter={filter}
                  fetchDataFn={fetchDataFn}
                  searchDancesJson={searchDancesJson}
                  pageCount={pageCount}
                />
              </>
            ),
          },
          { name: "program", body: <div>Coming Eventually!</div> },
        ]}
      />
    </div>
  )
}

export default AdvancedSearch
