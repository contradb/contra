import React, { useContext } from "react"
import LibFigure from "./libfigure/libfigure"
import DialectContext from "./dialect-context"

export const FigureSearchExEditorExtras = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
}) => {
  const dialect = useContext(DialectContext)
  return (
    <>
      <select
        className="form-control search-ex-figure"
        onChange={({ target: { value } }) =>
          setSearchEx(searchEx.shallowCopy({ move: value }))
        }
      >
        <MoveMenuOptions dialect={dialect} />
      </select>
      <input
        type="checkbox"
        checked={searchEx.ellipsis}
        onChange={() =>
          setSearchEx(searchEx.shallowCopy({ ellipsis: !searchEx.ellipsis }))
        }
      />
    </>
  )
}

const MoveMenuOptions = React.memo(({ dialect }: { dialect: Dialect }) => (
  <>
    {[
      { term: "*", substitution: "any figure" },
      ...moveTermsAndSubstitutionsForSelectMenu(dialect),
    ].map(({ term, substitution }, i) => (
      <option key={i} value={term}>
        {substitution}
      </option>
    ))}
  </>
))

const moveTermsAndSubstitutionsForSelectMenu: (
  dialect: Dialect
) => { term: string; substitution: string }[] =
  LibFigure.moveTermsAndSubstitutionsForSelectMenu

export default FigureSearchExEditorExtras
