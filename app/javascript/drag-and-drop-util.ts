import { ActivityId } from "./models/activity"

export const danceDraggableId = (danceId: number): string => `dance-${danceId}`
export const activityDraggableId = (activityId: ActivityId): string => `activity-${activityId}`