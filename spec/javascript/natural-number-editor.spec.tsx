import React from "react"
import { render, fireEvent } from "@testing-library/react"

import NaturalNumberEditor from "../../app/javascript/natural-number-editor"

describe("NaturalNumberEditor", () => {
  let value: number
  let setValue: any

  beforeEach(() => {
    value = 250624
    setValue = jest.fn((x: number) => {
      value = x
    })
  })

  it("works", () => {
    const { getByDisplayValue } = render(
      <NaturalNumberEditor value={value} setValue={setValue} />
    )
    const field = getByDisplayValue(value.toString())
    fireEvent.change(field, { target: { value: 36 } })
    expect(setValue).toHaveBeenCalledWith(36)
    expect(setValue).toHaveBeenCalledTimes(1)
  })

  describe("className", () => {
    it("renders with .form-control", () => {
      const field = render(
        <NaturalNumberEditor value={value} setValue={setValue} />
      ).getByDisplayValue(value.toString())
      expect(field).toHaveClass("form-control")
    })

    it("appends .form-control to whatever they pass in in inputProperties", () => {
      const field = render(
        <NaturalNumberEditor
          value={value}
          setValue={setValue}
          inputProperties={{ className: "fuzzy-wuzzy" }}
        />
      ).getByDisplayValue(value.toString())
      expect(field).toHaveClass("fuzzy-wuzzy")
      expect(field).toHaveClass("form-control")
    })
  })
})
