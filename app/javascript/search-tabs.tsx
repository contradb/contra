import * as React from "react"
import { useState } from "react"

export type SearchTab = { name: string; body: JSX.Element }

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
          <a
            onClick={() => setSelectedIndex(index)}
            className={index === selectedIndex ? "selected" : ""}
            key={index}
          >
            {tab.name}
          </a>
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
