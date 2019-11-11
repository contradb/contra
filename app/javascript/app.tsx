import * as React from "react"
import { useState, useEffect, useMemo } from "react"
import { useTable } from "react-table"

import makeData from "./makeData"

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
      { Header: "Choreographer", accessor: "choreographer_name" },
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
