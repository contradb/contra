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
  byMe = false,
}: {
  all?: boolean
  sketchbook?: boolean
  off?: boolean
  byMe?: boolean
}): Filter => {
  const sbk = sketchbook
  const allFilters: Filter[] = all ? [["publish", "all"]] : []
  const sbkFilters: Filter[] = sbk ? [["publish", "sketchbook"]] : []
  const offFilters: Filter[] = off ? [["publish", "off"]] : []
  const byMeFilters: Filter[] = byMe ? [["by me"]] : []
  const filters: Filter[] = [
    ...byMeFilters,
    ...allFilters,
    ...sbkFilters,
    ...offFilters,
  ]
  if (3 == allFilters.length + sbkFilters.length + offFilters.length) {
    return matchEverything
  } else if (1 == filters.length) {
    return filters[0]
  } else {
    return ["or", ...filters]
  }
}
