import * as React from "react"
import { FC } from "react"

export const DropOntoEndOfProgram: FC<{
  isDroppable: boolean
  className: string
}> = ({ isDroppable = true, className = "", children }) => {
  return <div className={"red"}>{children}</div>
}
