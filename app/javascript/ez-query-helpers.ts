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
  byMe = false,
  off = false,
}: {
  all?: boolean
  sketchbook?: boolean
  byMe?: boolean
  off?: boolean
}): Filter => {
  const sbk = sketchbook
  const allFilters: Filter[] = all ? [["publish", "all"]] : []
  const sbkFilters: Filter[] = sbk ? [["publish", "sketchbook"]] : []
  const offFilters: Filter[] = off ? [["publish", "off"]] : []
  const filters: Filter[] = [...allFilters, ...sbkFilters, ...offFilters]
  switch (filters.length) {
    case 0:
      return byMe ? ["by me"] : matchNothing
    case 1:
      return byMe ? ["or", ["by me"], ...filters] : filters[0]
    case 2:
      return byMe ? ["or", ["by me"], ...filters] : ["or", ...filters]
    case 3:
      return matchEverything
    default:
      throw new Error("fell through case statement")
  }
}
