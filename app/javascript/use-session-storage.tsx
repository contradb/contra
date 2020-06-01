// from https://dev.to/gabe_ragland/debouncing-with-react-hooks-jci

import React, { useState, useEffect } from "react"

// key should not change from invocation to invocation. Put another
// way, a given callsite of useSessionStorage must always invoke with
// the same key, in addition to obeying the rules of hooks.
function useSessionStorage(
  key: string,
  initializerOrFn: string | (() => string)
): [string, (x: string) => void] {
  const stateAndSetState = useState(() => {
    const s = sessionStorage.getItem(key)
    return typeof s === "string"
      ? s
      : typeof initializerOrFn === "function"
      ? initializerOrFn()
      : initializerOrFn
  })
  const state = stateAndSetState[0]
  useEffect(() => {
    sessionStorage.setItem(key, state)
  }, [state])
  return stateAndSetState
}

export default useSessionStorage
