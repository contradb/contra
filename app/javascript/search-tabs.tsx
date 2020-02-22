import * as React from "react"
import { useState } from "react"

export type SearchTab = { name: string; loading?: boolean; body: JSX.Element }

export const SearchTabs = ({
  tabs,
  initialIndex,
}: {
  tabs: SearchTab[]
  initialIndex: number
}): JSX.Element => {
  const [selectedIndex, setSelectedIndex] = useState(initialIndex)
  return (
    <>
      <div className="search-tabs">
        {tabs.map((tab, index) => (
          <button
            onClick={() => setSelectedIndex(index)}
            className={index === selectedIndex ? "selected" : ""}
            key={index}
          >
            <span className={tab.loading ? "very-understated" : ""}>
              {tab.name}
            </span>
            {tab.loading ? (
              <span className="glyphicon glyphicon-repeat glyphicon-spin photobomb"></span>
            ) : (
              ""
            )}
          </button>
        ))}
      </div>
      {tabs.map((tab, index) => {
        const maybeHidden = index === selectedIndex ? "" : "hidden"
        return (
          <div className={maybeHidden} key={index}>
            {tab.body}
          </div>
        )
      })}
    </>
  )
}

export default SearchTabs
