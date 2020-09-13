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
  clear,
  isClear,
}: {
  loading: boolean
  filter: Filter
  fetchDataFn: FetchDataFn
  searchDancesJson: SearchDancesJson
  pageCount: number
  visibleColumns: boolean[]
  setVisibleColumns: (val: boolean[]) => void
  clear: () => void
  isClear: boolean
}): JSX.Element => (
  <>
    {loading && <div className="floating-loading-indicator">loading...</div>}
    <ClearSearchButton clear={clear} isClear={isClear} />
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

const ClearSearchButton = ({
  clear,
  isClear,
}: {
  clear: () => void
  isClear: boolean
}): JSX.Element => (
  <button
    className="btn btn-default"
    onClick={clear}
    style={isClear ? { visibility: "hidden" } : {}}
  >
    Clear Search
  </button>
)

export default DancesTab
