import React from "react"
// import { render, fireEvent } from "@testing-library/react"

import { getVerifiedFilter } from "../../app/javascript/advanced-search"

describe("getVerifiedFilter", () => {
  const offs = { v: false, nv: false, vbm: false, nvbm: false }

  it("v => 0 < tag", () => {
    expect(getVerifiedFilter({ ...offs, v: true })).toEqual([
      "or",
      ["compare", ["constant", 0], "<", ["tag", "verified"]],
    ])
  })

  it("nv => 0 = tag", () => {
    expect(getVerifiedFilter({ ...offs, nv: true })).toEqual([
      "or",
      ["compare", ["constant", 0], "=", ["tag", "verified"]],
    ])
  })

  it("v & nv => match everything", () => {
    expect(getVerifiedFilter({ ...offs, v: true, nv: true })).toEqual(["and"])
  })

  it("vbm => my-tag", () => {
    expect(getVerifiedFilter({ ...offs, vbm: true })).toEqual([
      "or",
      ["my tag", "verified"],
    ])
  })

  it("nvbm => no my-tag", () => {
    expect(getVerifiedFilter({ ...offs, nvbm: true })).toEqual([
      "or",
      ["no", ["my tag", "verified"]],
    ])
  })

  it("vbm & nvbm => match everything", () => {
    expect(getVerifiedFilter({ ...offs, vbm: true, nvbm: true })).toEqual([
      "and",
    ])
  })

  it("v & vbm => same as v", () => {
    expect(getVerifiedFilter({ ...offs, v: true, vbm: true })).toEqual(
      getVerifiedFilter({ ...offs, v: true })
    )
  })

  it("nv & nvbm => same as nvbm", () => {
    expect(getVerifiedFilter({ ...offs, nv: true, nvbm: true })).toEqual(
      getVerifiedFilter({ ...offs, nvbm: true })
    )
  })
})
