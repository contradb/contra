import React from "react"
import { render, fireEvent } from "@testing-library/react"

// these imports are something you'd normally configure Jest to import for you
// automatically. Learn more in the setup docs: https://testing-library.com/docs/react-testing-library/setup#cleanup
import "@testing-library/jest-dom/extend-expect"
// NOTE: jest-dom adds handy assertions to Jest and is recommended, but not required

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
