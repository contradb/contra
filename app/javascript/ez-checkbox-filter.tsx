import * as React from "react"

export const EzCheckboxFilter = ({
  checked,
  setChecked,
  label,
  inputId,
}: {
  checked: boolean
  setChecked: (x: boolean) => void
  label: string
  inputId: string
}) => {
  return (
    <div>
      <label>
        <input
          id={inputId}
          type="checkbox"
          checked={checked}
          onChange={e => setChecked(e.target.checked)}
        />
        &nbsp; {label}
      </label>
    </div>
  )
}

export default EzCheckboxFilter
