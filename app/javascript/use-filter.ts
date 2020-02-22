import { useState, useMemo } from "react"
import Filter from "./filter"
import {
  getVerifiedFilter,
  getPublishFilter,
  getFormationFilters,
} from "./ez-query-helpers"
import useDebounce from "./use-debounce"

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
  rememberState("hook", useState(""))
  rememberState("verifiedChecked", useState(true))
  rememberState("notVerifiedChecked", useState(false))
  rememberState("verifiedCheckedByMe", useState(false))
  rememberState("notVerifiedCheckedByMe", useState(false))
  rememberState("publishAll", useState(true))
  rememberState("publishSketchbook", useState(false))
  rememberState("publishOff", useState(false))
  rememberState("enteredByMe", useState(false))
  rememberState("improper", useState(true))
  rememberState("becket", useState(true))
  rememberState("proper", useState(true))
  rememberState("otherFormation", useState(true))

  const verifiedFilter: Filter = useMemo(
    () =>
      getVerifiedFilter({
        v: d.verifiedChecked,
        nv: d.notVerifiedChecked,
        vbm: d.verifiedCheckedByMe,
        nvbm: d.notVerifiedCheckedByMe,
      }),
    [
      d.verifiedChecked,
      d.notVerifiedChecked,
      d.verifiedCheckedByMe,
      d.notVerifiedCheckedByMe,
    ]
  )

  const debouncedChoreographer = useDebounce(d.choreographer)

  const choreographerFilters: Filter[] = useMemo(
    () =>
      debouncedChoreographer ? [["choreographer", debouncedChoreographer]] : [],
    [debouncedChoreographer]
  )

  const debouncedHook = useDebounce(d.hook)

  const hookFilters: Filter[] = useMemo(
    () => (debouncedHook ? [["hook", debouncedHook]] : []),
    [debouncedHook]
  )

  const publishFilter: Filter = useMemo(
    () =>
      getPublishFilter({
        all: d.publishAll,
        sketchbook: d.publishSketchbook,
        off: d.publishOff,
        byMe: d.enteredByMe,
      }),
    [d.publishAll, d.publishSketchbook, d.publishOff, d.enteredByMe]
  )
  const formationFilters: Filter[] = useMemo(
    () =>
      getFormationFilters({
        improper: d.improper,
        becket: d.becket,
        proper: d.proper,
        otherFormation: d.otherFormation,
      }),
    [d.improper, d.becket, d.proper, d.otherFormation]
  )
  const ezFilter: Filter = useMemo(
    () => [
      "and",
      verifiedFilter,
      publishFilter,
      ...[...choreographerFilters, ...hookFilters, ...formationFilters], // ts being grumpy!
    ],
    [
      verifiedFilter,
      publishFilter,
      choreographerFilters,
      hookFilters,
      formationFilters,
    ]
  )
  const grandFilter: Filter = useMemo(() => ["if", ezFilter, ["figure", "*"]], [
    ezFilter,
  ])

  return { filter: grandFilter, dictionary: d }
}
