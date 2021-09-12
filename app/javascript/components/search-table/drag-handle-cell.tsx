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
          className={"drag-handle-cell"}
          {...provided.draggableProps}
          {...provided.dragHandleProps}
          ref={provided.innerRef}
        >
          <span className="glyphicon glyphicon-move"></span>
        </div>
      )}
    </Draggable>
  )
}
