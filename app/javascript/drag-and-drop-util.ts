import { Activity } from "./models/activity"

export const danceDraggableId = (danceId: number): string => `dance-${danceId}`
export const activityDraggableId = ({ interimDraggableId }: Activity): string =>
  interimDraggableId
