import * as React from "react"
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
  const columns = React.useMemo(
    () =>
      [
        "Title",
        "Choreographer",
        "Hook",
        "Formation",
        "User",
        "Entered",
        "Updated",
        "Sharing",
        "Figures",
      ].map(x => {
        return {
          Header: x,
          accessor: x.toLowerCase(),
        }
      }),
    []
  )

  const data = React.useMemo(() => makeData(20), [])

  return <Table columns={columns} data={data} />
}

export default App
