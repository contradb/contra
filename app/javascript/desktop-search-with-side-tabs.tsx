import React, { useState, useCallback } from "react"
import OpenSideTabToggle from "./open-side-tab-toggle"
import IconizedSideTabToggle from "./iconized-side-tab-toggle"

export const DesktopSearchWithSideTabs = ({
  filtersTab,
  figuresTab,
  dancesTab,
  programTab,
}: {
  filtersTab: JSX.Element
  figuresTab: JSX.Element
  dancesTab: JSX.Element
  programTab: JSX.Element
}): JSX.Element => {
  const [filtersVisible, setFiltersVisible] = useState<boolean>(true)
  const [programVisible, setProgramVisible] = useState<boolean>(false)
  const onProgramToggle = useCallback(
    () => setProgramVisible(!programVisible),
    [programVisible, setProgramVisible]
  )
  const onFiltersToggle = useCallback(
    () => setFiltersVisible(!filtersVisible),
    [filtersVisible, setFiltersVisible]
  )
  return (
    <div className="advanced-search-desktop">
      <div className={filtersVisible ? "" : "hidden"}>
        <OpenSideTabToggle label="filters" onToggle={onFiltersToggle} />
        <div className="filters-desktop">{filtersTab}</div>
      </div>
      <div className="main-search-desktop">
        <div className="main-search-desktop-ljust">
          {filtersVisible || (
            <IconizedSideTabToggle label="filters" onToggle={onFiltersToggle} />
          )}
          <div className="main-search-desktop-mainy-main-main">
            <h1>Search Dances</h1>
            {figuresTab}
            {dancesTab}
          </div>
        </div>
        {programVisible || (
          <IconizedSideTabToggle label="program" onToggle={onProgramToggle} />
        )}
      </div>
      <div className={programVisible ? "" : "hidden"}>
        <OpenSideTabToggle label="program" onToggle={onProgramToggle} />
        <div className="program-desktop">{programTab}</div>
      </div>
    </div>
  )
}

export default DesktopSearchWithSideTabs
