import * as React from "react"
import { Draggable, DraggableProvided } from "react-beautiful-dnd"
import { activityDraggableId } from "../drag-and-drop-util"
import { Activity } from "../models/activity"

interface Props {
  index: number
  activity: Activity
}

export const DraggableActivity = ({ activity, index }: Props): JSX.Element => (
  <Draggable draggableId={activityDraggableId(activity)} index={index}>
    {(provided: DraggableProvided) => (
      <div
        className="draggable-activity"
        {...provided.draggableProps}
        {...provided.dragHandleProps}
        ref={provided.innerRef}
      >
        <b>{activity.dance?.title}</b> {activity.text}
      </div>
    )}
  </Draggable>
)
