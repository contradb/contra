import React from "react"

export const IconizedSideTab = ({
  label,
  onToggle,
}: {
  label: "program" | "filters"
  onToggle: () => void
}): JSX.Element => {
  const onRightSide = label === "program"
  const sideClass = onRightSide
    ? "side-panel-toggle-iconized-right"
    : "side-panel-toggle-iconized-left"
  const buttonClass = label === "program" ? "toggle-program" : "toggle-filters"
  const glyphicon = onRightSide ? "glyphicon-menu-left" : "glyphicon-menu-right"
  const button = (
    <div>
      <div
        className={`side-panel-toggle side-panel-toggle-iconized ${sideClass}`}
      >
        <button className={buttonClass} onClick={onToggle}>
          <h2>
            <div>
              <span className={"glyphicon " + glyphicon} />
            </div>
            {Array.from({ length: label.length }, (_, i) => (
              <div key={i}>{label.charAt(i)}</div>
            ))}
          </h2>
        </button>
      </div>
    </div>
  )
  return button
}

export default IconizedSideTab
