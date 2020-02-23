import React, { useState, useCallback } from "react"
import {
  FetchDataFn,
  sortByParam,
  SearchDancesDanceJson,
  SearchDancesJson,
} from "./dance-table"
import Filter from "./filter"
import useFilter from "use-filter"
import SearchTabs from "./search-tabs"
import FiltersTab from "./filters-tab"
import FiguresTab from "./figures-tab"
import DancesTab from "./dances-tab"
import ProgramTab from "./program-tab"

export const AdvancedSearch = (): JSX.Element => {
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
  const dancesTabName: string = `${searchDancesJson.numberMatching} dance${
    1 === searchDancesJson.numberMatching ? "" : "s"
  }`
  const filtersTab = <FiltersTab dictionary={dictionary} />
  const figuresTab = <FiguresTab />
  const dancesTab = (
    <DancesTab
      loading={loading}
      filter={filter}
      fetchDataFn={fetchDataFn}
      searchDancesJson={searchDancesJson}
      pageCount={pageCount}
    />
  )
  const programTab = <ProgramTab />
  return (
    <div>
      <SearchTabs
        initialIndex={2}
        tabs={[
          { name: "filters", body: filtersTab },
          { name: "figures", body: figuresTab },
          { name: dancesTabName, body: dancesTab, loading: loading },
          { name: "program", body: programTab },
        ]}
      />
    </div>
  )
}

export default AdvancedSearch
