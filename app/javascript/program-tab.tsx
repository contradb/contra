import * as React from "react"
import { useContext } from "react"
import { Droppable } from "react-beautiful-dnd"
import { DraggableActivity } from "./components/draggable-activity"
import { Context } from "./components/program-editor-drag-drop-context"
import { Activity, activityReactKey } from "./models/activity"

export const ProgramTab = (): JSX.Element => {
  const [{ activities }] = useContext(Context)
  return (
    <Droppable droppableId="program">
      {({ droppableProps, placeholder, innerRef }) => (
        <div ref={innerRef} {...droppableProps}>
          {activities.map((activity: Activity, index: number) => (
            <DraggableActivity
              activity={activity}
              key={activityReactKey(activity)}
              index={index}
            />
          ))}
          {placeholder}
        </div>
      )}
    </Droppable>
  )
}
export default ProgramTab
