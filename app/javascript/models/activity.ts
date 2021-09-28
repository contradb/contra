import { Dance } from "./dance"

export type Activity = {
  id?: ActivityId
  dance?: Dance
  text: string
  interimDraggableId: string
}

export type ActivityId = number

export const activityReactKey = ({ interimDraggableId }: Activity): string =>
  interimDraggableId
