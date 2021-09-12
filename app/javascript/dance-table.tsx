import * as React from "react"
import { useEffect } from "react"
import { useTable, usePagination, useSortBy } from "react-table"
import { NaturalNumberEditor } from "./natural-number-editor"
import Filter from "./filter"
import { Breakpoint } from "./use-bootstrap3-breakpoint"
import { Droppable } from "react-beautiful-dnd"
import { DragHandleCell } from "./components/search-table/drag-handle-cell"
import { Dance } from "./models/dance"

// TODO: use rails route helpers
const choreographerPath = (cid: number): string => {
  return "/choreographers/" + cid
}
const userPath = (cid: number): string => {
  return "/users/" + cid
}
const dancePath = (danceId: number): string => {
  return "/dances/" + danceId
}

const ChoreographerCell = (props: any): JSX.Element => {
  const values: SearchDancesDanceJson = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return (
    <a href={choreographerPath(values.choreographer_id)}>
      {values.choreographer_name}
    </a>
  )
}

const UserCell = (props: any): JSX.Element => {
  const values: SearchDancesDanceJson = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return <a href={userPath(values.user_id)}>{values.user_name}</a>
}

const DanceTitleCell = (props: any): JSX.Element => {
  const values: SearchDancesDanceJson = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
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
  Header: React.ReactNode
  accessor: string
  Cell?: (props: any) => JSX.Element
  show: Breakpoint.Xs | Breakpoint.Md | false
  disableSortBy?: boolean
}

export const columnDefinitions: Array<ColumnDefinition> = [
  {
    Header: "Title",
    accessor: "title",
    Cell: DanceTitleCell,
    show: Breakpoint.Xs,
  },
  {
    Header: "Choreographer",
    accessor: "choreographer_name",
    Cell: ChoreographerCell,
    show: Breakpoint.Xs,
  },
  { Header: "Hook", accessor: "hook", show: Breakpoint.Xs },
  { Header: "Formation", accessor: "formation", show: Breakpoint.Md },
  {
    Header: "User",
    accessor: "user_name",
    Cell: UserCell,
    show: Breakpoint.Md,
  },
  {
    Header: "Entered",
    accessor: "created_at",
    Cell: CreatedAtDateCell,
    show: Breakpoint.Md,
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
  {
    Header: <span className="glyphicon glyphicon-share-alt"></span>,
    accessor: "id",
    Cell: DragHandleCell,
    show: Breakpoint.Xs,
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
  column: any // ColumnInstance<SearchDancesDanceJson>
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

export type FetchDataFn = ({
  pageSize,
  pageIndex,
  sortBy,
  filter,
}: {
  pageSize: number
  pageIndex: number
  sortBy: SortBy
  filter: Filter
}) => void

export function DanceTable({
  searchDancesJson,
  fetchDataFn,
  pageCount: controlledPageCount,
  filter,
  initialSortBy = [],
  visibleColumns,
  setVisibleColumns,
  setDanceSearchResults,
}: {
  searchDancesJson: SearchDancesJson
  fetchDataFn: FetchDataFn
  pageCount: number
  filter: Filter
  initialSortBy?: any // SortBy
  visibleColumns: boolean[]
  setVisibleColumns: (val: boolean[]) => void
  setDanceSearchResults: (dances: Array<Dance>) => void
}): JSX.Element {
  // const tableState = useTableState({ pageIndex: 0 })
  // const [{ pageIndex, pageSize }] = tableState

  const tableOptions = {
    columns: columnDefinitions,
    data: searchDancesJson.dances,
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
    setDanceSearchResults(rows.map((row: any) => row.original))
  }, [rows, setDanceSearchResults])

  useEffect(() => {
    if (columnDefinitions.length !== columns.length)
      throw new Error("columns and columnDefinitions are not the same length")
    for (let i = 0; i < columns.length; i++) {
      const show = visibleColumns[i]
      const shown: boolean = columns[i].getToggleHiddenProps().checked
      if (show !== shown) columns[i].toggleHidden(!show)
    }
  }, [columns, visibleColumns])

  // again, need to worry about the return value of this first arg to useEffect
  useEffect(() => fetchDataFn({ pageIndex, pageSize, sortBy, filter }), [
    fetchDataFn,
    pageIndex,
    pageSize,
    sortBy,
    filter,
  ])

  return (
    <>
      <ColumnVisToggles
        columns={columns}
        visibleColumns={visibleColumns}
        setVisibleColumns={setVisibleColumns}
      />

      <Droppable droppableId="dance-table" isDropDisabled={true}>
        {({ droppableProps, placeholder, innerRef: droppableRef }) => (
          <div ref={droppableRef} {...droppableProps}>
            {placeholder}
            <table
              {...getTableProps()}
              className="table table-bordered table-hover table-condensed dances-table-react"
            >
              <thead>
                {headerGroups.map((headerGroup: any) => (
                  // eslint-disable-next-line react/jsx-key
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
                    // eslint-disable-next-line react/jsx-key
                    <tr {...row.getRowProps()}>
                      {row.cells.map((cell: any) => (
                        // eslint-disable-next-line react/jsx-key
                        <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                      ))}
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </Droppable>
      <div className="dance-table-footer">
        <div className="form-inline">
          <PaginationSentence
            pageOffset={pageIndex * pageSize}
            pageCount={searchDancesJson.dances.length}
            matchCount={searchDancesJson.numberMatching}
            isFiltered={
              searchDancesJson.numberMatching !==
              searchDancesJson.numberSearched
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

export interface SearchDancesDanceJson {
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

export interface SearchDancesJson {
  numberSearched: number
  numberMatching: number
  dances: Array<SearchDancesDanceJson>
}

const ColumnVisToggles = ({
  columns,
  visibleColumns,
  setVisibleColumns,
}: {
  columns: any[]
  visibleColumns: boolean[]
  setVisibleColumns: (val: boolean[]) => void
}): JSX.Element => {
  return (
    <div className="table-column-vis-wrap">
      <label>Show columns </label>
      <div className="table-column-vis-toggles">
        {columns.map((column, i) => (
          <ColumnVisToggle
            column={column}
            visible={visibleColumns[i]}
            setVisible={vis => {
              const copy = [...visibleColumns]
              copy[i] = vis
              setVisibleColumns(copy)
            }}
            key={i}
          />
        ))}
      </div>
    </div>
  )
}

const ColumnVisToggle = ({
  column,
  visible,
  setVisible,
}: {
  column: any
  visible: boolean
  setVisible: (vis: boolean) => void
}): JSX.Element => {
  const toggleVisClass = visible ? "toggle-vis-active" : "toggle-vis-inactive"
  const className = "btn btn-xs " + toggleVisClass
  return (
    <button className={className} onClick={() => setVisible(!visible)}>
      {column.Header}
    </button>
  )
}

export default DanceTable
