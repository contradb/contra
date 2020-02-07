import Filter from "./filter"

export const matchNothing: Filter = ["or"] //  kinda non-obvious how to express tihs in filters, eh?
export const matchEverything: Filter = ["and"] //  kinda non-obvious how to express tihs in filters, eh?

export const getVerifiedFilter = ({
  v,
  nv,
  vbm,
  nvbm,
}: {
  v: boolean
  nv: boolean
  vbm: boolean
  nvbm: boolean
}): Filter => {
  const r: Filter = ["or"]
  if (v) {
    if (nv) {
      return matchEverything
    } else {
      r.push(["compare", ["constant", 0], "<", ["tag", "verified"]])
    }
  } else {
    if (nv) {
      nvbm || r.push(["compare", ["constant", 0], "=", ["tag", "verified"]])
    } else {
      // do nothing
    }
  }
  if (vbm) {
    if (nvbm) {
      return matchEverything
    } else {
      v || r.push(["my tag", "verified"])
    }
  } else {
    if (nvbm) {
      r.push(["no", ["my tag", "verified"]])
    } else {
      // do nothing
    }
  }
  return r
}

export const getPublishFilter = ({
  all = false,
  sketchbook = false,
  off = false,
}: {
  all?: boolean
  sketchbook?: boolean
  off?: boolean
}): Filter => {
  const sbk = sketchbook
  const allFilters: Filter[] = all ? [["publish", "all"]] : []
  const offFilters: Filter[] = off ? [["publish", "off"]] : []
  const sbkFilters: Filter[] = sbk ? [["publish", "sketchbook"]] : []
  const filters: Filter[] = [...allFilters, ...sbkFilters, ...offFilters]
  switch (filters.length) {
    case 0:
      return matchNothing
    case 1:
      return filters[0]
    case 2:
      return ["or", ...filters]
    case 3:
      return matchEverything
    default:
      throw new Error("fell through case statement")
  }
}
