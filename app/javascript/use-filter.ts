import { useMemo } from "react"
import Filter from "./filter"
import {
  getVerifiedFilter,
  getPublishFilter,
  getFormationFilters,
} from "./ez-query-helpers"
import useDebounce from "./use-debounce"
import useSessionStorage from "./use-session-storage"

const setterName = (s: string): string => {
  const first = s.charAt(0).toUpperCase()
  const rest = s.slice(1)
  return "set" + first + rest
}

interface FilterState {
  title: string
  choreographer: string
  user: string
  hook: string
  verifiedChecked: boolean
  notVerifiedChecked: boolean
  verifiedCheckedByMe: boolean
  notVerifiedCheckedByMe: boolean
  publishAll: boolean
  publishSketchbook: boolean
  publishOff: boolean
  enteredByMe: boolean
  improper: boolean
  becket: boolean
  proper: boolean
  otherFormation: boolean
}

const defaultFilterState: FilterState = {
  title: "",
  choreographer: "",
  user: "",
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

const defaultFilterString = JSON.stringify(defaultFilterState)

export default function useFilter(
  coreFilter: Filter
): {
  filter: Filter
  dictionary: object
  clearFilter: () => void
  isFilterClear: boolean
} {
  const [sessionStorage, setSessionStorage] = useSessionStorage(
    "filterState",
    defaultFilterString
  )
  const clearFilter = (): void => setSessionStorage(defaultFilterString)
  const states = JSON.parse(sessionStorage)
  const setStates = (value: FilterState): void =>
    setSessionStorage(JSON.stringify(value))
  // loop over keys and make setters,
  const setters: { [key: string]: (newState: boolean | string) => void } = {}
  for (const stateName in defaultFilterState)
    setters[setterName(stateName)] = newState =>
      setStates({ ...states, [stateName]: newState })
  const d = { ...states, ...setters }

  const isFilterClear = wellIsTheFilterClear(states)

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

  const debouncedTitle = useDebounce(d.title)

  const titleFilters: Filter[] = useMemo(
    () => (debouncedTitle ? [["title", debouncedTitle]] : []),
    [debouncedTitle]
  )

  const debouncedChoreographer = useDebounce(d.choreographer)

  const choreographerFilters: Filter[] = useMemo(
    () =>
      debouncedChoreographer ? [["choreographer", debouncedChoreographer]] : [],
    [debouncedChoreographer]
  )

  const debouncedUser = useDebounce(d.user)

  const userFilters: Filter[] = useMemo(
    () => (debouncedUser ? [["user", debouncedUser]] : []),
    [debouncedUser]
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
      ...[
        ...titleFilters,
        ...choreographerFilters,
        ...userFilters,
        ...hookFilters,
        ...formationFilters,
      ], // ts being grumpy!
    ],
    [
      verifiedFilter,
      publishFilter,
      titleFilters,
      choreographerFilters,
      userFilters,
      hookFilters,
      formationFilters,
    ]
  )
  const grandFilter: Filter = useMemo(() => ["if", ezFilter, coreFilter], [
    ezFilter,
    coreFilter,
  ])

  return { filter: grandFilter, dictionary: d, clearFilter, isFilterClear }
}

const wellIsTheFilterClear = (filter: FilterState): boolean => {
  for (const key in defaultFilterState) {
    if ((filter as any)[key] !== (defaultFilterState as any)[key]) {
      return false
    }
  }
  return true
}
