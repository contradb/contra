import * as React from "react"

import { DanceTable, FetchDataFn, SearchDancesJson } from "./dance-table"
import Filter from "./filter"

export const DancesTab = ({
  loading,
  filter,
  fetchDataFn,
  searchDancesJson,
  pageCount,
}: {
  loading: boolean
  filter: Filter
  fetchDataFn: FetchDataFn
  searchDancesJson: SearchDancesJson
  pageCount: number
}): JSX.Element => (
  <>
    {loading && <div className="floating-loading-indicator">loading...</div>}
    <DanceTable
      filter={filter}
      fetchDataFn={fetchDataFn}
      searchDancesJson={searchDancesJson}
      pageCount={pageCount}
    />
  </>
)

export default DancesTab
