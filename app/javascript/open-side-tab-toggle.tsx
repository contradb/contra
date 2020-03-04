import React from "react"

export const OpenSideTabToggle = ({
  label,
  onToggle,
}: {
  label: "program" | "filters"
  onToggle: () => void
}): JSX.Element => {
  const onRightSide = label === "program"
  const buttonClass = label === "program" ? "toggle-program" : "toggle-filters"
  const sidePanelToggleOpenSide = onRightSide
    ? "side-panel-toggle-open-right"
    : "side-panel-toggle-open-left"
  const glyphicon = onRightSide ? "glyphicon-menu-right" : "glyphicon-menu-left"
  const classes = `side-panel-toggle side-panel-toggle-open ${sidePanelToggleOpenSide}`
  const button = (
    <div className={classes}>
      <button className={buttonClass} onClick={onToggle}>
        <h2>
          {onRightSide ? <span>{label}</span> : null}
          <span className={"glyphicon " + glyphicon} />
          {onRightSide ? null : <span>{label}</span>}
        </h2>
      </button>
    </div>
  )
  return button
}

export default OpenSideTabToggle
