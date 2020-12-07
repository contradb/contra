import * as React from "react"

import { DanceTable, FetchDataFn, SearchDancesJson } from "./dance-table"
import Filter from "./filter"

export const DancesTab = ({
  loading,
  filter,
  fetchDataFn,
  searchDancesJson,
  pageCount,
  visibleColumns,
  setVisibleColumns,
}: {
  loading: boolean
  filter: Filter
  fetchDataFn: FetchDataFn
  searchDancesJson: SearchDancesJson
  pageCount: number
  visibleColumns: boolean[]
  setVisibleColumns: (val: boolean[]) => void
}): JSX.Element => (
  <>
    {loading && <div className="floating-loading-indicator">loading...</div>}
    <DanceTable
      filter={filter}
      fetchDataFn={fetchDataFn}
      searchDancesJson={searchDancesJson}
      pageCount={pageCount}
      visibleColumns={visibleColumns}
      setVisibleColumns={setVisibleColumns}
    />
  </>
)

export default DancesTab
