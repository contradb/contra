import * as React from "react"
import { useState, useEffect, useMemo, useCallback } from "react"
import { useTable, usePagination } from "react-table"

function Table({
  columns,
  data,
  fetchData,
  loading,
  pageCount: controlledPageCount,
}: {
  columns: any
  data: any
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
      data,
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

  // Render the UI for your table
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
      <div className="pagination">
        <button onClick={() => gotoPage(0)} disabled={!canPreviousPage}>
          {"<<"}
        </button>{" "}
        <button onClick={() => previousPage()} disabled={!canPreviousPage}>
          {"<"}
        </button>{" "}
        <button onClick={() => nextPage()} disabled={!canNextPage}>
          {">"}
        </button>{" "}
        <button onClick={() => gotoPage(pageCount - 1)} disabled={!canNextPage}>
          {">>"}
        </button>{" "}
        <span>
          Page{" "}
          <strong>
            {pageIndex + 1} of {pageOptions.length}
          </strong>{" "}
        </span>
        <span>
          | Go to page:{" "}
          <input
            type="number"
            defaultValue={pageIndex + 1}
            onChange={e => {
              const page = e.target.value ? Number(e.target.value) - 1 : 0
              gotoPage(page)
            }}
            style={{ width: "100px" }}
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
  const nullDances: DanceSearchResult[] = []
  const [dancesGetJson, setDancesGetJson] = useState({
    dances: nullDances,
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
      console.log('fetch("/api/v1/dances")')
      const response = await fetch("/api/v1/dances")
      const json: DancesGetJson = await response.json()
      setDancesGetJson(json)
      setPageCount(Math.ceil(json.numberMatching / pageSize))
      setLoading(false)
    }
    fetchData()
    // maybe return in-use-ness to prevent a memory leak here?
  }, [])

  // useEffect(() => {
  //   let used = true
  //   async function fetchData() {
  //     if (used) {
  //       const r = await fetch("/api/v1/dances")
  //       const json: DancesGetJson = await r.json()
  //       console.log('fetch("/api/v1/dances")')
  //       setDancesGetJson(json)
  //     }
  //   }
  //   fetchData()
  //   return () => {
  //     used = false
  //   }
  // }, [])

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
        data={dances}
        fetchData={fetchData}
        loading={loading}
        pageCount={pageCount}
      />
      <div>
        Showing {offset + 1} to {offset + dances.length} of
        {" " + numberMatching + " "}
        {numberMatching === numberSearched || "filtered"} dances.
      </div>
    </>
  )
}

export default DanceTable
