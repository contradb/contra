import React, { ChangeEvent } from "react"
import { SearchEx, ConstantNumericEx } from "./search-ex"

export const ConstantNumericExEditorExtras = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: ConstantNumericEx
  setSearchEx: (se: SearchEx) => void
}): JSX.Element => {
  const onChange = (e: ChangeEvent<HTMLInputElement>): void =>
    setSearchEx(
      searchEx.shallowCopy({
        number: e.target.value ? parseInt(e.target.value) : 0,
      })
    )
  return (
    <tr>
      <td colSpan={2}>
        <input
          type="number"
          className="form-control constant-numeric-value"
          value={searchEx.number}
          onChange={onChange}
          min={0}
          step="1"
        />
      </td>
    </tr>
  )
}

export default ConstantNumericExEditorExtras
