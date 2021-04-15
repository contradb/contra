import * as React from "react"
import { Draggable, DraggableProvided } from "react-beautiful-dnd"
import { Activity } from "../models/activity"

interface Props {
  index: number
  activity: Activity
}

export const DraggableActivity = ({ activity, index }: Props): JSX.Element => (
  <Draggable draggableId={activity.id.toString()} index={index}>
    {(provided: DraggableProvided) => (
      <div
        {...provided.draggableProps}
        {...provided.dragHandleProps}
        ref={provided.innerRef}
      >
        <b>{activity.danceId}</b> {activity.text}
      </div>
    )}
  </Draggable>
)
