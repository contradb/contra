import * as React from "react"
import { useState, useEffect, useMemo, useCallback } from "react"
import { useTable, usePagination } from "react-table"
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
    <div>
      Showing {pageOffset + 1} to {pageOffset + pageCount} of {matchCount}{" "}
      {isFiltered && "filtered"} dances.
    </div>
  )
}

function Table({
  columns,
  dancesGetJson,
  fetchData,
  loading,
  pageCount: controlledPageCount,
}: {
  columns: any
  dancesGetJson: DancesGetJson
  fetchData: Function
  loading: boolean
  pageCount: number
}) {
  // const tableState = useTableState({ pageIndex: 0 })
  // const [{ pageIndex, pageSize }] = tableState

  const {
    getTableProps,
    headerGroups,
    prepareRow,
    page, // new
    canPreviousPage, // new
    canNextPage, // new
    pageOptions, // new
    pageCount, // new
    gotoPage, // new
    nextPage, // new
    previousPage, // new
    setPageSize, // new
    getTableBodyProps,
    rows,
    pageIndex,
    pageSize,
  } = useTable(
    {
      columns,
      data: dancesGetJson.dances,
      manualPagination: true,
      pageCount: controlledPageCount,
    },
    usePagination
  )

  // again, need to worry about the return value of this first arg to useEffect
  useEffect(() => fetchData({ pageIndex, pageSize }), [
    fetchData,
    pageIndex,
    pageSize,
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
                <th {...column.getHeaderProps()}>{column.render("Header")}</th>
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
      <PaginationSentence
        pageOffset={pageIndex * pageSize}
        pageCount={dancesGetJson.dances.length}
        matchCount={dancesGetJson.numberMatching}
        isFiltered={
          dancesGetJson.numberMatching !== dancesGetJson.numberSearched
        }
      />
      <div className="pagination">
        <TurnPageButton
          onClick={() => {
            gotoPage(0)
          }}
          isDisabled={!canPreviousPage}
          glyphicon="glyphicon-fast-backward"
        />{" "}
        <TurnPageButton
          onClick={previousPage}
          isDisabled={!canPreviousPage}
          glyphicon="glyphicon-play"
          iconIsFlipped={true}
        />{" "}
        <TurnPageButton
          onClick={nextPage}
          isDisabled={!canNextPage}
          glyphicon="glyphicon-play"
        />{" "}
        <TurnPageButton
          onClick={() => {
            gotoPage(pageCount - 1)
          }}
          isDisabled={!canNextPage}
          glyphicon="glyphicon-fast-forward"
        />{" "}
        <span>
          Go to page:{" "}
          <NaturalNumberEditor
            value={pageIndex + 1}
            setValue={n => gotoPage(n - 1)}
            inputProperties={{
              className: "page-number-entry",
              style: { width: "100px" },
            }}
          />
        </span>{" "}
        <select
          value={pageSize}
          onChange={e => {
            setPageSize(Number(e.target.value))
          }}
        >
          {[10, 20, 30, 40, 50].map(pageSize => (
            <option key={pageSize} value={pageSize}>
              Show {pageSize}
            </option>
          ))}
        </select>
      </div>
    </>
  )
}

function TurnPageButton({
  onClick,
  isDisabled = false,
  glyphicon,
  iconIsFlipped = false,
}: {
  onClick: () => void
  isDisabled?: boolean
  glyphicon: string
  iconIsFlipped?: boolean
}) {
  const flipClass: string | false = iconIsFlipped && "flipped-glyphicon"
  return (
    <button className="btn btn-default" onClick={onClick} disabled={isDisabled}>
      <span className={`glyphicon ${glyphicon} ${flipClass}`}></span>
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
  figures?: string
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
  const fetchData = useCallback(({ pageSize, pageIndex }) => {
    setLoading(true)
    async function fetchData() {
      const url = `/api/v1/dances?count=${pageSize}&offset=${pageIndex *
        pageSize}`
      console.log(`fetch("${url}")`)
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
      />
    </>
  )
}

export default DanceTable
