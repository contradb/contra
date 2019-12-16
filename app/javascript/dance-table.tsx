import * as React from "react"
import { useState, useEffect, useMemo, useCallback } from "react"
import { useTable, usePagination, useSortBy } from "react-table"
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
}) {
  return (
    <span>
      Showing {pageOffset + 1} to {pageOffset + pageCount} of {matchCount}{" "}
      {isFiltered && "filtered"} dances.
    </span>
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
  columns,
  dancesGetJson,
  fetchData,
  loading,
  pageCount: controlledPageCount,
  initialSortBy,
}: {
  columns: any
  dancesGetJson: DancesGetJson
  fetchData: Function
  loading: boolean
  pageCount: number
  initialSortBy: any // SortBy
}) {
  // const tableState = useTableState({ pageIndex: 0 })
  // const [{ pageIndex, pageSize }] = tableState

  const tableOptions = {
    columns,
    data: dancesGetJson.dances,
    manualPagination: true,
    pageCount: controlledPageCount,
    initialState: { sortBy: initialSortBy },
  }
  const {
    getTableProps,
    headerGroups,
    prepareRow,
    page,
    canPreviousPage,
    canNextPage,
    pageOptions,
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

  console.log("render table")

  return (
    <>
      <table
        {...getTableProps()}
        className="table table-bordered table-hover table-condensed dances-table-react"
      >
        <thead>
          {headerGroups.map(headerGroup => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map(column => (
                <th {...column.getHeaderProps(column.getSortByToggleProps())}>
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    {column.render("Header")}{" "}
                    {/* Add a sort direction indicator */}
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
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row, i) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map(cell => {
                  return <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                })}
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
}) {
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
const choreographerPath = (cid: number) => {
  return "/choreographers/" + cid
}
const dancePath = (dance_id: number) => {
  return "/dances/" + dance_id
}

const ChoreographerCell = (props: any) => {
  const values: DanceSearchResult = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return (
    <a href={choreographerPath(values.choreographer_id)}>
      {values.choreographer_name}
    </a>
  )
}

const DanceTitleCell = (props: any) => {
  const values: DanceSearchResult = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return <a href={dancePath(values.id)}>{values.title}</a>
}

const MatchingFiguresHtmlCell = (props: any) => (
  <div
    dangerouslySetInnerHTML={{
      __html: props.row.values.matching_figures_html,
    }}
  />
)

function DanceTable() {
  const offset = 0
  const [dancesGetJson, setDancesGetJson] = useState({
    dances: [] as DanceSearchResult[],
    numberSearched: 0,
    numberMatching: 0,
  })
  const {
    dances,
    numberSearched,
    numberMatching,
  }: DancesGetJson = dancesGetJson

  const [pageCount, setPageCount] = React.useState(0)
  const [loading, setLoading] = React.useState(false)
  const fetchData = useCallback(({ pageSize, pageIndex, sortBy }) => {
    setLoading(true)
    async function fetchData() {
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
    fetchData()
    // maybe return in-use-ness to prevent a memory leak here?
  }, [])

  const columnsArr = [
    {
      Header: "Title",
      accessor: "title",
      Cell: DanceTitleCell,
      // show: () => titleVisible,
    },
    {
      Header: "Choreographer",
      accessor: "choreographer_name",
      Cell: ChoreographerCell,
    },
    { Header: "Hook", accessor: "hook" },
    { Header: "Formation", accessor: "formation" },
    { Header: "User", accessor: "user_name" },
    { Header: "Entered", accessor: "created_at" },
    { Header: "Updated", accessor: "updated_at", show: false },
    { Header: "Sharing", accessor: "publish", show: false },
    {
      Header: "Figures",
      accessor: "matching_figures_html",
      show: false,
      Cell: MatchingFiguresHtmlCell,
    },
  ]
  const [visibleToggles, setVisibleToggles] = useState(
    columnsArr.map(ca => ca.show || !ca.hasOwnProperty("show"))
  )
  // const toggleTitleVisible = () => setTitleVisible(!titleVisible)
  const columns = useMemo(
    () =>
      columnsArr.map((ca, i) => {
        return { ...ca, show: () => visibleToggles[i] }
      }),
    visibleToggles
  )

  return (
    <>
      <div className="table-column-vis-wrap">
        <label>Show columns </label>
        <div className="table-column-vis-toggles">
          {columnsArr.map((ca, i) => {
            const toggleVisFn = () =>
              setVisibleToggles(
                visibleToggles.map((vis, j) => (i === j) !== vis)
              )
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
