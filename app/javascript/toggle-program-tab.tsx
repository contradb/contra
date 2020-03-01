import React from "react"

export const ToggleProgramTab = ({
  onToggle,
  open,
}: {
  onToggle: () => void
  open: boolean
}): JSX.Element => {
  const glyphicon = open ? "glyphicon-menu-right" : "glyphicon-menu-left"
  const openCloseStyle = open ? "" : "side-panel-toggle-closed"
  const labelText = "program"
  let label
  if (open) label = labelText
  else {
    label = []
    for (let i = 0; i < labelText.length; i++)
      label.push(<div>{labelText.charAt(i)}</div>)
  }

  const button = (
    <div className="side-panel-toggle-container">
      <div className={`side-panel-toggle ${openCloseStyle}`}>
        <button className="toggle-program" onClick={onToggle}>
          <h2>
            <div>
              <span className={"glyphicon " + glyphicon} />
            </div>
            {label}
          </h2>
        </button>
      </div>
    </div>
  )
  return button
}

export default ToggleProgramTab
