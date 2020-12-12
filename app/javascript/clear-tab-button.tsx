import * as React from "react"

export const ClearTabButton = ({
  name,
  clear,
  isClear,
}: {
  name: string
  clear: () => void
  isClear: boolean
}): JSX.Element => (
  <button
    className="btn btn-default clear-button"
    onClick={clear}
    style={isClear ? { visibility: "hidden" } : {}}
  >
    Clear {name}
  </button>
)

export default ClearTabButton
