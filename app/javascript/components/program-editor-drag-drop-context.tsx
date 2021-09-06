import React, { createContext, FunctionComponent, useState } from "react"
import { DragDropContext, DropResult } from "react-beautiful-dnd"
import { Activity } from "../models/activity"
import { Dance } from "../models/dance"
import { Program } from "../models/program"

const defaultPrograms: Program[] = [
  {
    title: "new program",
    activities: [
      { id: 456, index: 0, dance: { id: 7, title: "Box the Gnat" }, text: "" },
      { id: undefined, index: 1, dance: { id: 24, title: "Butter" }, text: "" },
      { id: 457, index: 2, text: "Waltz" },
      { id: 458, index: 3, text: "Break" },
      {
        id: 459,
        index: 4,
        dance: { id: 8, title: "Triple Mud Pig" },
        text: "",
      },
      {
        id: 460,
        index: 5,
        dance: { id: 1000, title: "The Baby Rose" },
        text: "",
      },
      { id: 461, index: 6, text: "Waltz" },
    ],
  },
]

const reindex: <T extends { index: number }>(a: T[]) => T[] = activities =>
  activities.map((x, index) => ({ ...x, index }))

const onDragEnd = (
  programs: Program[],
  setPrograms: (ps: Program[]) => void,
  danceSearchResults: Array<Dance>
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
  const activities: Activity[] = [...programs[0].activities]
  if (destination.droppableId === source.droppableId) {
    const activity: Activity = programs[0].activities[source.index]
    activities.splice(source.index, 1)
    activities.splice(destination.index, 0, activity)
  } else {
    const dance = danceSearchResults[source.index]
    const activity: Activity = makeActivityFromDance(dance)
    console.log({ activity })
    activities.splice(destination.index, 0, activity)
  }
  const newProgram = { ...programs[0], activities: reindex(activities) }

  setPrograms([newProgram])
}

const makeActivityFromDance: (d: Dance) => Activity = dance => ({
  index: -1357,
  dance,
  text: "",
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
