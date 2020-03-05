// from https://dev.to/gabe_ragland/debouncing-with-react-hooks-jci

import React, { useState, useEffect, useRef } from "react"

export default function useDebounce<T>(
  value: T,
  {
    delay = 500,
    bouncyFirstRun = true,
  }: { delay?: number; bouncyFirstRun?: boolean } = {
    delay: 500,
    bouncyFirstRun: true,
  }
): T {
  const [debouncedValue, setDebouncedValue] = useState(value)
  const isFirstRun = useRef(true)
  useEffect(() => {
    if (bouncyFirstRun && isFirstRun.current) {
      isFirstRun.current = false
      setDebouncedValue(value)
    } else {
      const handler = setTimeout(() => {
        console.log("setTimeout resolve")
        setDebouncedValue(value)
      }, delay)
      return () => {
        clearTimeout(handler)
      }
    }
  }, [value])

  return debouncedValue
}
