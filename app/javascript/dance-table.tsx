import * as React from "react"
import { useState, useEffect, useMemo, useCallback } from "react"
import {
  useTable,
  usePagination,
  useSortBy,
  ColumnInstance,
  Cell,
} from "react-table"
import { NaturalNumberEditor } from "./natural-number-editor"

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

function DanceTableThLabel({
  column,
}: {
  column: ColumnInstance<DanceSearchResult>
}): JSX.Element {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
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

function Table(args: {
  columns: any
  dancesGetJson: DancesGetJson
  fetchData: Function
  loading: boolean
  pageCount: number
  initialSortBy: any // SortBy
}): JSX.Element {
  const {
    columns,
    dancesGetJson,
    fetchData,
    loading,
    pageCount: controlledPageCount,
    initialSortBy,
  } = args
  // const tableState = useTableState({ pageIndex: 0 })
  // const [{ pageIndex, pageSize }] = tableState

  const tableOptions = {
    columns,
    data: dancesGetJson.dances,
    manualPagination: true,
    manualSortBy: true, // after 7.0.0-rc2
    manualSorting: true, // before 7.0.0-rc2
    pageCount: controlledPageCount,
    initialState: { sortBy: initialSortBy },
  }
  const {
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
    pageIndex,
    pageSize,
    state: { sortBy },
  } = useTable(tableOptions, useSortBy, usePagination)

  // again, need to worry about the return value of this first arg to useEffect
  useEffect(() => fetchData({ pageIndex, pageSize, sortBy }), [
    fetchData,
    pageIndex,
    pageSize,
    sortBy,
  ])

  console.log("render table", args)
  if (dancesGetJson.numberMatching > 100) {
    // debugger
  }

  return (
    <>
      {loading && <div className="floating-loading-indicator">loading...</div>}
      <table
        {...getTableProps()}
        className="table table-bordered table-hover table-condensed dances-table-react"
      >
        <thead>
          {headerGroups.map(headerGroup => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps(column.getSortByToggleProps())}>
                  <DanceTableThLabel column={column} />
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map(row => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map(cell => (
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
  publish: string //  "myself" | "everyone" | "link"
  figures: string
}

interface DancesGetJson {
  numberSearched: number
  numberMatching: number
  dances: Array<DanceSearchResult>
}

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

const CreatedAtDateCell = (props: Cell): JSX.Element =>
  DateCell(props.row.values.created_at)

const UpdatedAtDateCell = (props: Cell): JSX.Element => {
  return DateCell(props.row.values.updated_at)
}
// time looks like: '2019-10-13T06:22:08.818Z'
const DateCell = (time: string): JSX.Element => (
  <>{new Date(time).toLocaleDateString()}</>
)

const MatchingFiguresHtmlCell = (props: Cell): JSX.Element => (
  <div
    dangerouslySetInnerHTML={{
      __html: props.row.values.matching_figures_html,
    }}
  />
)

const columnsArr: Array<{
  Header: string
  accessor: string
  Cell?: (props: any) => JSX.Element
  show: boolean
}> = [
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
  },
]

function DanceTable(): JSX.Element {
  const [dancesGetJson, setDancesGetJson] = useState({
    dances: [] as DanceSearchResult[],
    numberSearched: 0,
    numberMatching: 0,
  })

  const [pageCount, setPageCount] = React.useState(0)
  const [loading, setLoading] = React.useState(false)
  const fetchData = useCallback(({ pageSize, pageIndex, sortBy }) => {
    setLoading(true)
    async function fetchData1(): Promise<void> {
      const offset = pageIndex * pageSize
      const sort = sortByParam(sortBy)
      const url = `/api/v1/dances?count=${pageSize}&offset=${offset}&sort_by=${sort}`
      console.log(`fetch("${url}")`, pageSize, pageIndex, sortBy)
      const response = await fetch(url)
      const json: DancesGetJson = await response.json()
      setDancesGetJson(json)
      setPageCount(Math.ceil(json.numberMatching / pageSize))
      setLoading(false)
    }
    fetchData1()
    // maybe return in-use-ness to prevent a memory leak here?
  }, [])

  const [visibleToggles, setVisibleToggles] = useState(
    columnsArr.map(ca => ca.show)
  )
  // const toggleTitleVisible = () => setTitleVisible(!titleVisible)
  const columns = useMemo(
    () => columnsArr.map((ca, i) => ({ ...ca, show: () => visibleToggles[i] })),
    [visibleToggles]
  )

  return (
    <>
      <div className="table-column-vis-wrap">
        <label>Show columns </label>
        <div className="table-column-vis-toggles">
          {columnsArr.map((ca, i) => {
            const toggleVisFn = (): void => {
              setVisibleToggles(
                visibleToggles.map((vis, j) => (i === j) !== vis)
              )
            }
            const toggleVisClass = visibleToggles[i]
              ? "toggle-vis-active"
              : "toggle-vis-inactive"
            return (
              <button
                key={i}
                className={"btn btn-xs " + toggleVisClass}
                onClick={toggleVisFn}
              >
                {ca.Header}
              </button>
            )
          })}
        </div>
      </div>
      <Table
        columns={columns}
        dancesGetJson={dancesGetJson}
        fetchData={fetchData}
        loading={loading}
        pageCount={pageCount}
        initialSortBy={[]}
      />
    </>
  )
}

export default DanceTable
