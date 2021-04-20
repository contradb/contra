import * as React from "react"
import { useState } from "react"
import { Droppable } from "react-beautiful-dnd"
import { DraggableActivity } from "./components/draggable-activity"
import { Activity } from "./models/activity"

export const ProgramTab = (): JSX.Element => {
  const [activities, _setActivities] = useState<Array<Activity>>([
    { id: 456, index: 0, danceId: 7, text: "Box the Gnat" },
    { id: -1, index: 1, danceId: 24, text: "Butter" },
    { id: 457, index: 2, text: "Waltz" },
    { id: 458, index: 3, text: "Break" },
    { id: 459, index: 4, danceId: 8, text: "Double Mud Pig" },
    { id: 460, index: 5, danceId: 1000, text: "The Baby Rose" },
    { id: 461, index: 6, text: "Waltz" },
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
