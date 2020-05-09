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

export default function useFilter(
  coreFilter: Filter
): { filter: Filter; dictionary: object } {
  const defaultStates = {
    choreographer: "",
    hook: "",
    verifiedChecked: true,
    notVerifiedChecked: false,
    verifiedCheckedByMe: false,
    notVerifiedCheckedByMe: false,
    publishAll: true,
    publishSketchbook: false,
    publishOff: false,
    enteredByMe: false,
    improper: true,
    becket: true,
    proper: true,
    otherFormation: true,
  }
  const [states, setStates] = useState(defaultStates)
  // loop over keys and make setters,
  const setters: { [index: string]: (newState: boolean | string) => void } = {}
  for (let stateName in defaultStates)
    setters[setterName(stateName)] = newState =>
      setStates({ ...states, [stateName]: newState })
  const d = { ...states, ...setters }

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
  const grandFilter: Filter = useMemo(() => ["if", ezFilter, coreFilter], [
    ezFilter,
    coreFilter,
  ])

  return { filter: grandFilter, dictionary: d }
}
