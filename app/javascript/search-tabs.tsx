import * as React from "react"
import { FC, useState } from "react"
import { Droppable, DroppableProvidedProps } from "react-beautiful-dnd"
import { DropOntoEndOfProgram } from "./components/drop-onto-end-of-program"

export type SearchTab = {
  name: string
  loading?: boolean
  body: JSX.Element
  margin?: boolean
  isDroppable?: boolean
}

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
        {tabs.map(({ loading, name, isDroppable }, index) => {
          const onClick = (): void => setSelectedIndex(index)
          const buttonClassName = index === selectedIndex ? "selected" : ""
          const spanClassName = loading ? "very-understated" : ""
          const loadingIcon = loading && (
            <span className="glyphicon glyphicon-repeat glyphicon-spin photobomb"></span>
          )
          const Button: FC<{
            droppableProps?: DroppableProvidedProps
            placeholder?: React.ReactNode
            innerRef?: (e: HTMLElement | null) => any
          }> = ({ droppableProps, placeholder, innerRef }) => (
            <button
              onClick={onClick}
              className={buttonClassName}
              {...droppableProps}
              ref={innerRef}
            >
              <span className={spanClassName}>
                {name}
                {placeholder}
              </span>
              {loadingIcon}
            </button>
          )
          return isDroppable ? (
            <Droppable key={index} droppableId="program-end-drop">
              {props => <Button {...props} />}
            </Droppable>
          ) : (
            <Button key={index} />
          )
        })}
      </div>
      {tabs.map(({ margin, body }, index) => {
        const maybeHidden = index === selectedIndex ? "" : "hidden"
        const classes = maybeHidden + (margin ? " search-tab-margin" : "")
        return (
          <div className={classes} key={index}>
            {body}
          </div>
        )
      })}
    </>
  )
}

export default SearchTabs
