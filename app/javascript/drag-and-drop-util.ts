import { Activity } from "./models/activity"

export const danceDraggableId = (danceId: number): string => `dance-${danceId}`
export const activityDraggableId = (activity: Activity): string => {
  const { id, dance } = activity
  if (id) {
    return `activity-${id}`
  } else if (dance) {
    return `dance-${dance.id}`
  } else {
    throw new Error(`can't concoct activityDraggableId from ${activity}`)
  }
}
