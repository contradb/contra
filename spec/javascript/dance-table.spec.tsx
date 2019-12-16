import React from "react"
// import { render, fireEvent } from "@testing-library/react"

import { sortByParam } from "../../app/javascript/dance-table"

describe("sortByParam", () => {
  it("works", () => {
    const sortBy = [
      { id: "title" },
      { id: "choreographer_name", desc: false },
      { id: "hook", desc: true },
    ]
    expect(sortByParam(sortBy)).toBe("titleAchoreographer_nameAhookD")
  })
})
