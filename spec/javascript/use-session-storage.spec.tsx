import React from "react"
import { renderHook, act } from "@testing-library/react-hooks"

import useSessionStorage from "../../app/javascript/use-session-storage"

const key = "testKeyWhatever"

describe("initializer parameter", () => {
  it("accepts a function returning a string", () => {
    const initialState = "5"
    const { result } = renderHook(() =>
      useSessionStorage(key, () => initialState)
    )
    expect(result.current[0]).toBe(initialState)
  })

  it("accepts a string", () => {
    const initialState = "5"
    const { result } = renderHook(() => useSessionStorage(key, initialState))
    expect(result.current[0]).toBe(initialState)
  })
})

describe("returned setter", () => {
  it("generates a rerender when it detects a change", () => {
    const { result } = renderHook(() => useSessionStorage(key, "5"))

    expect(result.current[0]).toBe("5")
    act(() => {
      const [val, setVal] = result.current
      setVal("6")
    })

    expect(result.current[0]).toBe("6")
  })

  it("sets sessionStorage", () => {
    const { result } = renderHook(() => useSessionStorage(key, "5"))

    act(() => {
      const [val, setVal] = result.current
      setVal("6")
    })

    expect(sessionStorage.getItem(key)).toBe("6")
  })
})
