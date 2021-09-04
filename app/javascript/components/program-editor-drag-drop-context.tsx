import React, {
  createContext,
  FunctionComponent,
  useContext,
  useState,
} from "react"
import { DragDropContext, DropResult } from "react-beautiful-dnd"
import { Activity } from "../models/activity"
import { Program } from "../models/program"

const defaultPrograms: Program[] = [
  {
    title: "new program",
    activities: [
      { id: 456, index: 0, danceId: 7, text: "Box the Gnat" },
      { id: -1, index: 1, danceId: 24, text: "Butter" },
      { id: 457, index: 2, text: "Waltz" },
      { id: 458, index: 3, text: "Break" },
      { id: 459, index: 4, danceId: 8, text: "Triple Mud Pig" },
      { id: 460, index: 5, danceId: 1000, text: "The Baby Rose" },
      { id: 461, index: 6, text: "Waltz" },
    ],
  },
]

const onDragEnd = (
  programs: Program[],
  setPrograms: (ps: Program[]) => void
) => ({ destination, source }: DropResult): void => {
  console.log("TODO here to enable dnd from dances to program", {
    source,
    destination,
  })
  if (!destination) return
  if (
    destination.droppableId === source.droppableId &&
    destination.index === source.index
  )
    return
  const activities = [...programs[0].activities]
  activities.splice(source.index, 1)
  activities.splice(destination.index, 0, programs[0].activities[source.index])
  const newProgram = { ...programs[0], activities }

  setPrograms([newProgram])
}

export const Context = createContext<Program[]>(defaultPrograms)

export const ProgramEditorDragDropContext: FunctionComponent<{}> = props => {
  const [programs, setPrograms] = useState<Program[]>(defaultPrograms)
  return (
    <Context.Provider value={programs}>
      <DragDropContext onDragEnd={onDragEnd(programs, setPrograms)}>
        {props.children}
      </DragDropContext>
    </Context.Provider>
  )
}
