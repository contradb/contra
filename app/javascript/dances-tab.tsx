import * as React from "react"

import { DanceTable, FetchDataFn, SearchDancesJson } from "./dance-table"
import Filter from "./filter"
import { Dance } from "./models/dance"

export const DancesTab = ({
  loading,
  filter,
  fetchDataFn,
  searchDancesJson,
  pageCount,
  visibleColumns,
  setVisibleColumns,
  setDanceSearchResults,
}: {
  loading: boolean
  filter: Filter
  fetchDataFn: FetchDataFn
  searchDancesJson: SearchDancesJson
  pageCount: number
  visibleColumns: boolean[]
  setVisibleColumns: (val: boolean[]) => void
  setDanceSearchResults: (dances: Array<Dance>) => void
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
      setDanceSearchResults={setDanceSearchResults}
    />
  </>
)

export default DancesTab
