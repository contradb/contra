// from https://dev.to/gabe_ragland/debouncing-with-react-hooks-jci

import React, { useState, useEffect } from "react"

// useSessionStorage is kinda like useState, but it stores the state
// in ... session storage!
//
// The first parameter, 'key', should be invoked wiht a string literal
// (a computed value could get sessionStorage state out of sync with
// useState state)
//
// The second parameter is an initializer. Like the parameter to
// useState, it can be either a value or a zero-parameter function that
// returns a value. Unlike useState, the value must be a string.
//
// like useState, this returns [string, setString]
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
