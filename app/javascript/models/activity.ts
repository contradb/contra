export interface Activity {
  index: number
  id: number // negative if it hasn't been saved to the DB yet?
  danceId?: number
  text: string
}

