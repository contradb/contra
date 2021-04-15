import * as React from "react"
import { useState } from "react"
import { Droppable } from "react-beautiful-dnd"
import { DraggableActivity } from "./components/draggable-activity"
import { Activity } from "./models/activity"

export const ProgramTab = (): JSX.Element => {
  const [activities, setActivities] = useState<Array<Activity>>([
    { id: 457, index: 0, danceId: 7, text: "Box the Gnat" },
    { id: -22, index: 1, danceId: 24, text: "Butter" },
    { id: 458, index: 2, text: "Waltz" },
  ])
  return (
    <Droppable droppableId="program">
      {({ droppableProps, placeholder, innerRef }) => (
        <div ref={innerRef} {...droppableProps}>
          {activities.map((activity, index) => (
            <DraggableActivity
              activity={activity}
              key={activity.id}
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
