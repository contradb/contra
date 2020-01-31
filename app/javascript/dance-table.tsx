import * as React from "react"
import { useState, useEffect, useCallback } from "react"
import { useTable, usePagination, useSortBy } from "react-table"
import { NaturalNumberEditor } from "./natural-number-editor"
import useDebounce from "./use-debounce"

// TODO: use rails route helpers
const choreographerPath = (cid: number): string => {
  return "/choreographers/" + cid
}
const dancePath = (danceId: number): string => {
  return "/dances/" + danceId
}

const ChoreographerCell = (props: any): JSX.Element => {
  const values: DanceSearchResult = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return (
    <a href={choreographerPath(values.choreographer_id)}>
      {values.choreographer_name}
    </a>
  )
}

const DanceTitleCell = (props: any): JSX.Element => {
  const values: DanceSearchResult = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return <a href={dancePath(values.id)}>{values.title}</a>
}

// time looks like: '2019-10-13T06:22:08.818Z'
const DateCell = (time: string): JSX.Element => (
  <>{new Date(time).toLocaleDateString()}</>
)

const CreatedAtDateCell = (props: any /* Cell */): JSX.Element =>
  DateCell(props.row.values.created_at)

const UpdatedAtDateCell = (props: any /* Cell */): JSX.Element =>
  DateCell(props.row.values.updated_at)

const MatchingFiguresHtmlCell = (props: any /* Cell */): JSX.Element => (
  <div
    dangerouslySetInnerHTML={{
      __html: props.row.values.matching_figures_html,
    }}
  />
)

type ColumnDefinition = {
  Header: string
  accessor: string
  Cell?: (props: any) => JSX.Element
  show: boolean
  disableSortBy?: boolean
}

const columnDefinitions: Array<ColumnDefinition> = [
  {
    Header: "Title",
    accessor: "title",
    Cell: DanceTitleCell,
    show: true,
  },
  {
    Header: "Choreographer",
    accessor: "choreographer_name",
    Cell: ChoreographerCell,
    show: true,
  },
  { Header: "Hook", accessor: "hook", show: true },
  { Header: "Formation", accessor: "formation", show: true },
  { Header: "User", accessor: "user_name", show: true },
  {
    Header: "Entered",
    accessor: "created_at",
    Cell: CreatedAtDateCell,
    show: true,
  },
  {
    Header: "Updated",
    accessor: "updated_at",
    Cell: UpdatedAtDateCell,
    show: false,
  },
  { Header: "Sharing", accessor: "publish", show: false },
  {
    Header: "Figures",
    accessor: "matching_figures_html",
    show: false,
    Cell: MatchingFiguresHtmlCell,
    disableSortBy: true,
  },
]

function PaginationSentence({
  pageOffset,
  pageCount,
  matchCount,
  isFiltered,
}: {
  pageOffset: number
  pageCount: number
  matchCount: number
  isFiltered: boolean
}): JSX.Element {
  return (
    <span>
      Showing {pageOffset + 1} to {pageOffset + pageCount} of {matchCount}{" "}
      {isFiltered && "filtered"} dances.
    </span>
  )
}

function DanceTableTh({
  column,
}: {
  column: any // ColumnInstance<DanceSearchResult>
}): JSX.Element {
  return (
    <th
      {...column.getHeaderProps(column.getSortByToggleProps())}
      className={"dance-table-th"}
    >
      <div>
        {column.render("Header")} {/* Add a sort direction indicator */}
        {column.isSorted ? (
          <span
            className={
              "glyphicon " +
              (column.isSortedDesc
                ? "glyphicon-sort-by-attributes-alt"
                : "glyphicon-sort-by-attributes")
            }
            style={{ opacity: 0.5 }}
          ></span>
        ) : (
          <span
            className="glyphicon glyphicon-sort"
            style={{ opacity: 0.2 }}
          ></span>
        )}
      </div>
    </th>
  )
}

// see allso the type SortingRule<D>
type SortByElement = {
  id: string // "title" | "choreographer_name" | "hook" | "formation" | "user_name" | "created_at" | "updated_at"
  desc?: boolean
}
export type SortBy = Array<SortByElement>

export const sortByParam = (sortBy: SortBy): string =>
  sortBy
    .map(sbe => (sbe.id ? sbe.id + (sbe.desc ? "D" : "A") : sbe + "A"))
    .join("")

function Table({
  dancesGetJson,
  fetchData,
  loading,
  pageCount: controlledPageCount,
  filter,
  initialSortBy,
}: {
  dancesGetJson: DancesGetJson
  fetchData: Function
  loading: boolean
  pageCount: number
  filter: any
  initialSortBy: any // SortBy
}): JSX.Element {
  // const tableState = useTableState({ pageIndex: 0 })
  // const [{ pageIndex, pageSize }] = tableState

  const tableOptions = {
    columns: columnDefinitions,
    data: dancesGetJson.dances,
    manualPagination: true,
    manualSortBy: true, // after 7.0.0-rc2
    manualSorting: true, // before 7.0.0-rc2
    pageCount: controlledPageCount,
    initialState: { sortBy: initialSortBy },
  }
  const {
    flatColumns: columns,
    getTableProps,
    headerGroups,
    prepareRow,
    canPreviousPage,
    canNextPage,
    pageCount,
    gotoPage,
    nextPage,
    previousPage,
    setPageSize,
    getTableBodyProps,
    rows,
    state: { sortBy, pageIndex, pageSize },
  } = useTable(tableOptions, useSortBy, usePagination)

  useEffect(() => {
    if (columnDefinitions.length !== columns.length)
      throw new Error("columns and columnDefinitions are not the same length")
    // first time through hide the columns that should be born hidden
    for (let i = 0; i < columns.length; i++)
      if (!columnDefinitions[i].show) columns[i].toggleHidden(true)
  }, [columns])

  const debouncedFilter = useDebounce(filter, {
    delay: 800,
    bouncyFirstRun: true,
  })

  // again, need to worry about the return value of this first arg to useEffect
  useEffect(
    () => fetchData({ pageIndex, pageSize, sortBy, filter: debouncedFilter }),
    [fetchData, pageIndex, pageSize, sortBy, debouncedFilter]
  )

  return (
    <>
      {loading && <div className="floating-loading-indicator">loading...</div>}
      <ColumnVisToggles columns={columns} />
      <table
        {...getTableProps()}
        className="table table-bordered table-hover table-condensed dances-table-react"
      >
        <thead>
          {headerGroups.map((headerGroup: any) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column: any) => (
                <DanceTableTh column={column} key={column.index} />
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row: any) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell: any) => (
                  <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                ))}
              </tr>
            )
          })}
        </tbody>
      </table>
      <div className="dance-table-footer">
        <div className="form-inline">
          <PaginationSentence
            pageOffset={pageIndex * pageSize}
            pageCount={dancesGetJson.dances.length}
            matchCount={dancesGetJson.numberMatching}
            isFiltered={
              dancesGetJson.numberMatching !== dancesGetJson.numberSearched
            }
          />
        </div>
        <div className="form-inline">
          <label>
            Results per page:{" "}
            <select
              value={pageSize}
              onChange={e => {
                setPageSize(Number(e.target.value))
              }}
              className="form-control"
            >
              {[10, 30, 100].map(pageSize => (
                <option key={pageSize}>{pageSize}</option>
              ))}
            </select>
          </label>
        </div>
        <div className="form-inline">
          <label>
            Go to page:{" "}
            <NaturalNumberEditor
              value={pageIndex + 1}
              setValue={n => gotoPage(n - 1)}
              inputProperties={{
                className: "page-number-entry",
                style: { width: "100px" },
              }}
            />
          </label>{" "}
        </div>
        <div className="">
          <div className="pagination">
            <TurnPageButton
              onClick={() => {
                gotoPage(0)
              }}
              isDisabled={!canPreviousPage}
              label="<<"
            />{" "}
            <TurnPageButton
              onClick={previousPage}
              isDisabled={!canPreviousPage}
              label="<"
            />{" "}
            <TurnPageButton
              onClick={nextPage}
              isDisabled={!canNextPage}
              label=">"
            />{" "}
            <TurnPageButton
              onClick={() => {
                gotoPage(pageCount - 1)
              }}
              isDisabled={!canNextPage}
              label=">>"
            />
          </div>
        </div>
      </div>
    </>
  )
}

function TurnPageButton({
  label,
  onClick,
  isDisabled = false,
}: // glyphicon,
// iconIsFlipped = false,
{
  label: "<<" | "<" | ">" | ">>"
  onClick: () => void
  isDisabled?: boolean
  // glyphicon: string
  // iconIsFlipped?: boolean
}): JSX.Element {
  let glyphicon: string
  if (label === "<<") glyphicon = "glyphicon-fast-backward"
  else if (label === "<" || label === ">") glyphicon = "glyphicon-play"
  else if (label === ">>") glyphicon = "glyphicon-fast-forward"
  else throw new Error("unexpected label " + label)
  const flipClass: string = label === "<" ? " flipped-glyphicon" : ""

  return (
    <button
      className="btn btn-default"
      onClick={onClick}
      disabled={isDisabled}
      data-testid={label}
    >
      <span className={`glyphicon ${glyphicon}${flipClass}`}></span>
    </button>
  )
}

interface DanceSearchResult {
  id: number
  title: string
  choreographer_id: number
  choreographer_name: string
  formation: string
  hook: string
  user_id: number
  user_name: string
  created_at: string
  updated_at: string
  publish: string
  figures: string
}

interface DancesGetJson {
  numberSearched: number
  numberMatching: number
  dances: Array<DanceSearchResult>
}

const ColumnVisToggles = ({ columns }: { columns: any[] }): JSX.Element => {
  return (
    <div className="table-column-vis-wrap">
      <label>Show columns </label>
      <div className="table-column-vis-toggles">
        {columns.map((column, i) => (
          <ColumnVisToggle
            column={column}
            columnDefinition={columnDefinitions[i]}
            key={i}
          />
        ))}
      </div>
    </div>
  )
}

const ColumnVisToggle = ({
  column,
  columnDefinition,
}: {
  column: any
  columnDefinition: ColumnDefinition
}): JSX.Element => {
  const [vis, setVis] = useState(columnDefinition.show)
  const toggleVisClass = vis ? "toggle-vis-active" : "toggle-vis-inactive"
  const className = "btn btn-xs " + toggleVisClass
  const onChange = (e: any): void => {
    const e2 = { ...e, target: { checked: !vis } }
    setVis(!vis)
    return column.getToggleHiddenProps().onChange(e2)
  }
  return (
    <button className={className} onClick={onChange}>
      {column.Header}
    </button>
  )
}

function DanceTable({ filter }: { filter: any }): JSX.Element {
  const [dancesGetJson, setDancesGetJson] = useState({
    dances: [] as DanceSearchResult[],
    numberSearched: 0,
    numberMatching: 0,
  })

  const [pageCount, setPageCount] = React.useState(0)
  const [loading, setLoading] = React.useState(false)
  const fetchData = useCallback(({ pageSize, pageIndex, sortBy, filter }) => {
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
      const json: DancesGetJson = await response.json()
      setDancesGetJson(json)
      setPageCount(Math.ceil(json.numberMatching / pageSize))
      setLoading(false)
    }
    fetchData1()
    // maybe return in-use-ness to prevent a memory leak here?
  }, [])

  return (
    <Table
      dancesGetJson={dancesGetJson}
      fetchData={fetchData}
      loading={loading}
      pageCount={pageCount}
      filter={filter}
      initialSortBy={[]}
    />
  )
}

export default DanceTable
