export interface NumericIndex {
  index: number
}

export const reindex: <T extends NumericIndex>(a: T[]) => T[] = activities =>
  activities.map((x, index) => ({ ...x, index }))

export const index: <T>(a: T[]) => Array<T & NumericIndex> = activities =>
  activities.map((x, index) => ({ ...x, index }))
