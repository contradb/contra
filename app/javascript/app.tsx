import * as React from "react"
import { useState, useEffect, useMemo } from "react"
import { useTable } from "react-table"

function Table({ columns, data }: { columns: any; data: any }) {
  // Use the state and functions returned from useTable to build your UI
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable({
    columns,
    data,
  })

  // Render the UI for your table
  return (
    <table {...getTableProps()}>
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

// TODO: use rails route helpers
const choreographerPath = (cid: number) => {
  return "/choreographers/" + cid
}

const ChoreographerCell = (props: any) => {
  const values: DanceSearchResult = props.row.original // shouldn't I be looking at props.row.values? It only has the accessor'd field in the column definition.
  return (
    <a href={choreographerPath(values.choreographer_id)}>
      {values.choreographer_name}
    </a>
  )
}

function App() {
  const [dances, setDances] = useState([])

  useEffect(() => {
    let used = true
    async function fetchData() {
      if (used) {
        const r = await fetch("/api/v1/dances")
        const json = await r.json()
        setDances(json)
      }
    }
    fetchData()
    return () => {
      used = false
    }
  }, [])

  const columns = useMemo(
    () => [
      { Header: "Title", accessor: "title" },
      {
        Header: "Choreographer",
        accessor: "choreographer_name",
        Cell: ChoreographerCell,
      },
      { Header: "Hook", accessor: "hook" },
      { Header: "Formation", accessor: "formation" },
      { Header: "User", accessor: "user_name" },
      { Header: "Entered", accessor: "created_at" },
      { Header: "Updated", accessor: "updated_at" },
      { Header: "Sharing", accessor: "publish" },
    ],
    []
  )

  return <Table columns={columns} data={dances} />
}

export default App
