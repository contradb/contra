import React from "react"

type Props = {
  name: string
  inputClass: string
  value: string
  setValue: (value: string) => void
  toolTip: string
}

export const EzTextFilter = ({
  name,
  inputClass,
  value,
  setValue,
  toolTip,
}: Props): JSX.Element => (
  <>
    <h4>{name}:</h4>
    <input
      type="text"
      className={`${inputClass} ez-text-filter form-control`}
      value={value}
      onChange={e => setValue(e.target.value)}
      title={toolTip}
    />
  </>
)

export default EzTextFilter
