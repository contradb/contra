import React, { FunctionComponent } from "react"
import { DragDropContext, DropResult } from "react-beautiful-dnd"

const onDragEnd = ({ destination, source }: DropResult): void => {
  if (!destination) return
  if (
    destination.droppableId === source.droppableId &&
    destination.index === source.index
  )
    return
}

export const ProgramEditorDragDropContext: FunctionComponent<{}> = props => (
  <DragDropContext onDragEnd={onDragEnd}>{props.children}</DragDropContext>
)
