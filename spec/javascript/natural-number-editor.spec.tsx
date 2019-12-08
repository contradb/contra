import React from "react"
import { render, fireEvent } from "@testing-library/react"

import NaturalNumberEditor from "../../app/javascript/natural-number-editor"

it("works", () => {
  const testMessage = "Test Message"
  let value: number = 250624
  const setValue = jest.fn((x: number) => {
    value = x
  })
  const { getByDisplayValue } = render(
    <NaturalNumberEditor value={value} setValue={setValue} />
  )
  const field = getByDisplayValue("250624")
  fireEvent.change(field, { target: { value: 36 } })
  expect(setValue).toHaveBeenCalledWith(36)
  expect(setValue).toHaveBeenCalledTimes(1)
})
