import React, {
  createContext,
  FunctionComponent,
  useState,
  useEffect,
} from "react"
import { DragDropContext, DropResult } from "react-beautiful-dnd"
import { Activity } from "../models/activity"
import { Dance } from "../models/dance"
import { index } from "../models/numeric-index"
import { Program } from "../models/program"
import { webApi } from "../services/webApi"

let uniqIndex = 0
const mintIndex = (): number => ++uniqIndex
const mintInterimDraggableId = (): string => `interim-${mintIndex()}`

const defaultPrograms: Program[] = [
  {
    title: "new program",
    activities: index(
      [
        { id: 14, dance: { id: 1, title: "the Rendevouz" }, text: "" },
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
  useEffect(() => {
    console.log({ program: programs[0] })
    webApi.savePrograms(programs) // todo: worry about rejection
  }, [programs])
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
