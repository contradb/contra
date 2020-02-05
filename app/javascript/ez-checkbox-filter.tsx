import * as React from "react"

export const EzCheckboxFilter = ({
  checked,
  setChecked,
  disabled = false,
  name,
}: {
  checked: boolean
  setChecked: (x: boolean) => void
  disabled?: boolean
  name: string
}) => {
  const label = name
  const inputId = "ez-" + name.replace(/ /g, "-")

  return (
    <div>
      <label
        className={disabled ? "text-muted" : ""}
        title={disabled ? "log in to enable" : undefined}
      >
        <input
          id={inputId}
          type="checkbox"
          checked={checked}
          onChange={e => setChecked(e.target.checked)}
          disabled={disabled}
        />
        &nbsp; {label}
      </label>
    </div>
  )
}

export default EzCheckboxFilter
