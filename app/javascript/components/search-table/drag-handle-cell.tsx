import React from "react"
import { Draggable, DraggableProvided } from "react-beautiful-dnd"
import { SearchDancesDanceJson } from "../../dance-table"
import { danceDraggableId } from "../../drag-and-drop-util"
import { DanceId } from "../../models/dance"

export const DragHandleCell = (props: any): JSX.Element => {
  const values: SearchDancesDanceJson = props.row.original
  const danceId: DanceId = values.id
  const index = props.row.index
  return (
    <Draggable index={index} draggableId={danceDraggableId(danceId)}>
      {(provided: DraggableProvided) => (
        <div
          {...provided.draggableProps}
          {...provided.dragHandleProps}
          ref={provided.innerRef}
        >
          {danceDraggableId(danceId)}
        </div>
      )}
    </Draggable>
  )
}
