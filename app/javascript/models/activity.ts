import { Dance } from "./dance"

export interface Activity {
  index: number
  id?: ActivityId
  dance?: Dance
  text: string
}

export type ActivityId = number

export const activityReactKey = ({ id, dance }: Activity): number => {
  if (id) {
    // loaded from db
    return id
  } else if (dance) {
    // dragged over from dance results
    return -dance.id
  } else {
    throw new Error(
      "Surprisingly, this activity has neither an activityId nor a danceid"
    )
  }
}
