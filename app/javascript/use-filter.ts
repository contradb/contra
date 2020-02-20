import { useState } from "react"
import Filter from "./filter"
import {
  getVerifiedFilter,
  getPublishFilter,
  getFormationFilters,
} from "./ez-query-helpers"

const setterName = (s: string): string => {
  const first = s.charAt(0).toUpperCase()
  const rest = s.slice(1)
  return "set" + first + rest
}

export default function useFilter(): { filter: Filter; dictionary: object } {
  const d: any = {} // dictionary of state values and setters
  const rememberState = (name: string, [value, setter]: [any, any]) => {
    d[name] = value
    d[setterName(name)] = setter
  }
  rememberState("choreographer", useState(""))
  // const [choreographer, setChoreographer] = useState("")

  rememberState("hook", useState(""))
  // const [hook, setHook] = useState("")

  rememberState("verifiedChecked", useState(true))
  // const [verifiedChecked, setVerifiedChecked] = useState(true)

  rememberState("notVerifiedChecked", useState(false))
  // const [notVerifiedChecked, setNotVerifiedChecked] = useState(false)

  rememberState("verifiedCheckedByMe", useState(false))
  // const [verifiedCheckedByMe, setVerifiedCheckedByMe] = useState(false)

  rememberState("notVerifiedCheckedByMe", useState(false))
  // const [notVerifiedCheckedByMe, setNotVerifiedCheckedByMe] = useState(false)

  rememberState("publishAll", useState(true))
  // const [publishAll, setPublishAll] = useState(true)

  rememberState("publishSketchbook", useState(false))
  // const [publishSketchbook, setPublishSketchbook] = useState(false)

  rememberState("publishOff", useState(false))
  // const [publishOff, setPublishOff] = useState(false)

  rememberState("enteredByMe", useState(false))
  // const [enteredByMe, setEnteredByMe] = useState(false)

  rememberState("improper", useState(true))
  // const [improper, setImproper] = useState(true)

  rememberState("becket", useState(true))
  // const [becket, setBecket] = useState(true)

  rememberState("proper", useState(true))
  // const [proper, setProper] = useState(true)

  rememberState("otherFormation", useState(true))
  // const [otherFormation, setOtherFormation] = useState(true)

  const verifiedFilter: Filter = getVerifiedFilter({
    v: d.verifiedChecked,
    nv: d.notVerifiedChecked,
    vbm: d.verifiedCheckedByMe,
    nvbm: d.notVerifiedCheckedByMe,
  })
  const choreographerFilters: Filter[] = d.choreographer
    ? [["choreographer", d.choreographer]]
    : []
  const hookFilters: Filter[] = d.hook ? [["hook", d.hook]] : []
  const publishFilter: Filter = getPublishFilter({
    all: d.publishAll,
    sketchbook: d.publishSketchbook,
    off: d.publishOff,
    byMe: d.enteredByMe,
  })
  const formationFilters: Filter[] = getFormationFilters({
    improper: d.improper,
    becket: d.becket,
    proper: d.proper,
    otherFormation: d.otherFormation,
  })
  const ezFilter: Filter = [
    "and",
    verifiedFilter,
    publishFilter,
    ...[...choreographerFilters, ...hookFilters, ...formationFilters], // ts being grumpy!
  ]
  const grandFilter: Filter = ["if", ezFilter, ["figure", "*"]]

  return { filter: grandFilter, dictionary: d }
}
