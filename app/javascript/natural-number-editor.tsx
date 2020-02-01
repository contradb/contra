import * as React from "react"
import { useState } from "react"

// kidna want a 'min', so that I can set a minimum page number of 1

export function NaturalNumberEditor({
  value,
  setValue,
  inputProperties = {},
}: {
  value: number
  setValue: (n: number) => void
  inputProperties?: { className?: string; [others: string]: any }
}) {
  const [stringValue, setStringValue] = useState(value.toString())
  let className: string
  let inputPropertiesWithoutClassName
  if (inputProperties.className) {
    className = inputProperties.className + " form-control"
    inputPropertiesWithoutClassName = { ...inputProperties }
    delete inputPropertiesWithoutClassName.className
  } else {
    className = "form-control"
    inputPropertiesWithoutClassName = inputProperties
  }

  return (
    <input
      type="text"
      value={stringValue}
      onChange={e => {
        const sv = e.target.value.replace(/[^0-9]/g, "")
        setStringValue(sv)
        if (sv) setValue(Number(sv))
      }}
      className={className}
      {...inputPropertiesWithoutClassName}
    />
  )
}
export default NaturalNumberEditor
