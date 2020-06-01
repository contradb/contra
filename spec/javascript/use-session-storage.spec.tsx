import React from "react"
import { renderHook, act } from "@testing-library/react-hooks"

import useSessionStorage from "../../app/javascript/use-session-storage"

const key = "testKeyWhatever"

describe("initializer", () => {
  it("is a function", () => {
    const initialState = "5"
    const { result } = renderHook(() =>
      useSessionStorage(key, () => initialState)
    )
    expect(result.current[0]).toBe(initialState)
  })

  it("is not a function", () => {
    const initialState = "5"
    const { result } = renderHook(() => useSessionStorage(key, initialState))
    expect(result.current[0]).toBe(initialState)
  })
})

describe("returned setter", () => {
  it("rerenders when value changes", () => {
    const { result } = renderHook(() => useSessionStorage(key, "5"))

    expect(result.current[0]).toBe("5")
    act(() => {
      const [val, setVal] = result.current
      setVal("6")
    })

    expect(result.current[0]).toBe("6")
  })

  it("saves the stored value to sessionStorage", () => {
    const { result } = renderHook(() => useSessionStorage(key, "5"))

    act(() => {
      const [val, setVal] = result.current
      setVal("6")
    })

    expect(sessionStorage.getItem(key)).toBe("6")
  })
})
