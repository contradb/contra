import * as React from "react"

export const EzCheckboxFilter = ({
  checked,
  setChecked,
  name,
}: {
  checked: boolean
  setChecked: (x: boolean) => void
  name: string
}) => {
  const label = name
  const inputId = "ez-" + name.replace(/ /g, "-")

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
