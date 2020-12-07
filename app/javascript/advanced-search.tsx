import React, { useState, useCallback, useMemo } from "react"
import {
  FetchDataFn,
  sortByParam,
  SearchDancesDanceJson,
  SearchDancesJson,
} from "./dance-table"
import DialectContext from "./dialect-context"
import useFilter from "use-filter"
import { useBootstrap3Breakpoint, Breakpoint } from "use-bootstrap3-breakpoint"
import useSessionStorage from "./use-session-storage"
import SearchTabs from "./search-tabs"
import DesktopSearchWithSideTabs from "./desktop-search-with-side-tabs"
import FiltersTab from "./filters-tab"
import FiguresTab from "./figures-tab"
import DancesTab from "./dances-tab"
import ProgramTab from "./program-tab"
import { columnDefinitions } from "./dance-table"
import { SearchEx } from "./search-ex"

export const AdvancedSearch = ({
  dialect,
  tags, // eslint-disable-line @typescript-eslint/no-unused-vars
}: {
  dialect: Dialect
  tags: string[]
}): JSX.Element => {
  const [searchDancesJson, setSearchDancesJson] = useState({
    dances: [] as SearchDancesDanceJson[],
    numberSearched: 0,
    numberMatching: 0,
  })

  const [loading, setLoading] = useState(false)
  const [pageCount, setPageCount] = useState(0)

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
          sort_by: sort, // eslint-disable-line @typescript-eslint/camelcase
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
  const [searchExString, setSearchExString] = useSessionStorage(
    "searchEx",
    searchExDefaultJson
  )
  const isSearchExClear = searchExString === searchExDefaultJson
  const searchEx = useMemo(() => SearchEx.fromJson(searchExString), [
    searchExString,
  ])
  const setSearchEx = (searchEx: SearchEx): void =>
    setSearchExString(searchEx.toJson())
  const clearSearchEx = (): void => setSearchEx(SearchEx.default())

  const searchExLispMemo = useMemo(() => searchEx.toLisp(), [searchEx])
  const { filter, dictionary, clearFilter, isFilterClear } = useFilter(
    searchExLispMemo
  )

  const breakpoint = useBootstrap3Breakpoint()

  const [hiResVisibleColumns, setHiResVisibleColumns] = useState(
    columnDefinitions.map(c => c.show && c.show <= Breakpoint.Md)
  )
  const [loResVisibleColumns, setLoResVisibleColumns] = useState(
    columnDefinitions.map(c => c.show && c.show <= Breakpoint.Xs)
  )
  const visibleColumns =
    breakpoint < Breakpoint.Md ? loResVisibleColumns : hiResVisibleColumns
  const setVisibleColumns =
    breakpoint < Breakpoint.Md ? setLoResVisibleColumns : setHiResVisibleColumns

  const dancesTabName = `${searchDancesJson.numberMatching} dance${
    1 === searchDancesJson.numberMatching ? "" : "s"
  }`
  const filtersTab = (
    <FiltersTab
      dictionary={dictionary}
      isClear={isFilterClear}
      clear={clearFilter}
    />
  )
  const figuresTab = (
    <FiguresTab
      searchEx={searchEx}
      setSearchEx={setSearchEx}
      isClear={isSearchExClear}
      clear={clearSearchEx}
    />
  )
  const dancesTab = (
    <DancesTab
      loading={loading}
      filter={filter}
      fetchDataFn={fetchDataFn}
      searchDancesJson={searchDancesJson}
      pageCount={pageCount}
      visibleColumns={visibleColumns}
      setVisibleColumns={setVisibleColumns}
    />
  )
  const programTab = <ProgramTab />

  if (breakpoint >= Breakpoint.Md) {
    const tabs = { filtersTab, figuresTab, dancesTab, programTab }
    return provideDialect(dialect, <DesktopSearchWithSideTabs {...tabs} />)
  } else {
    return provideDialect(
      dialect,
      <SearchTabs
        initialIndex={2}
        tabs={[
          { name: "filters", body: filtersTab, margin: true },
          { name: "figures", body: figuresTab, margin: true },
          { name: dancesTabName, body: dancesTab, loading: loading },
          { name: "program", body: programTab, margin: true },
        ]}
      />
    )
  }
}

const searchExDefaultJson = SearchEx.default().toJson()

const provideDialect = (
  dialect: Dialect,
  component: JSX.Element
): JSX.Element => (
  <DialectContext.Provider value={dialect}>{component}</DialectContext.Provider>
)

export default AdvancedSearch
