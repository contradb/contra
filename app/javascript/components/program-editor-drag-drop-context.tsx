import React, { createContext, FunctionComponent, useState } from "react"
import { DragDropContext, DropResult } from "react-beautiful-dnd"
import { Activity } from "../models/activity"
import { Dance } from "../models/dance"
import { index, NumericIndex, reindex } from "../models/numeric-index"
import { Program } from "../models/program"

let uniqIndex = 0
const mintIndex = (): number => ++uniqIndex
const mintInterimDraggableId = (): string => `interim-${mintIndex()}`

const defaultPrograms: Program[] = [
  {
    title: "new program",
    activities: index(
      [
        { id: 456, dance: { id: 7, title: "Box the Gnat" }, text: "" },
        { id: undefined, dance: { id: 24, title: "Butter" }, text: "" },
        { id: 457, text: "Waltz" },
        { id: 458, text: "Break" },
        {
          id: 459,
          dance: { id: 8, title: "Triple Mud Pig" },
          text: "",
        },
        {
          id: 460,
          dance: { id: 1000, title: "The Baby Rose" },
          text: "",
        },
        { id: 461, text: "Waltz" },
      ].map(a => ({ ...a, interimDraggableId: mintInterimDraggableId() }))
    ),
  },
]

const onDragEnd = (
  programs: Program[],
  setPrograms: (ps: Program[]) => void,
  danceSearchResults: Array<Dance>
) => ({ destination, source }: DropResult): void => {
  console.log("beautiful DnD", { source, destination })
  if (!destination) return
  if (
    destination.droppableId === source.droppableId &&
    destination.index === source.index
  )
    return
  const activities: Activity[] = [...programs[0].activities]
  if (destination.droppableId === source.droppableId) {
    // drag from same program
    const activity: Activity = programs[0].activities[source.index]
    activities.splice(source.index, 1)
    activities.splice(destination.index, 0, activity)
  } else {
    const dance = danceSearchResults[source.index]
    const activity: Activity = makeActivityFromDance(dance)
    switch (destination.droppableId) {
      case "program-end-drop":
        activities.push(activity)
        break
      case "program":
        activities.splice(destination.index, 0, activity)
        break
      default:
        throw new Error("Attempt to drag into an unknown droppable")
    }
  }

  const newProgram = { ...programs[0], activities: index(activities) }
  console.log("activities:", newProgram.activities.map(x => x.index))

  setPrograms([newProgram])
}

const makeActivityFromDance = (dance: Dance): Activity => ({
  dance,
  text: "",
  interimDraggableId: mintInterimDraggableId(),
})

export const Context = createContext<Program[]>(defaultPrograms)
interface ProgramEditorDragDropContextInterface {
  danceSearchResults: Array<Dance>
}
export const ProgramEditorDragDropContext: FunctionComponent<
  ProgramEditorDragDropContextInterface
> = ({ children, danceSearchResults }) => {
  const [programs, setPrograms] = useState<Program[]>(defaultPrograms)
  return (
    <Context.Provider value={programs}>
      <DragDropContext
        onDragEnd={onDragEnd(programs, setPrograms, danceSearchResults)}
      >
        {children}
      </DragDropContext>
    </Context.Provider>
  )
}
