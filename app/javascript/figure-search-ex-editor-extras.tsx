import React, { useContext } from "react"
import LibFigure from "./libfigure/libfigure"
import DialectContext from "./dialect-context"
import { SearchEx, FigureSearchEx } from "./search-ex"

export const FigureSearchExEditorExtras = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: FigureSearchEx
  setSearchEx: (se: SearchEx) => void
}) => {
  const dialect = useContext(DialectContext)
  const moveIsAsterisk = searchEx.move === "*"
  const skipParams = moveIsAsterisk || !searchEx.ellipsis
  const formalParameters = moveIsAsterisk
    ? []
    : LibFigure.formalParameters(searchEx.move)
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
      {skipParams
        ? null
        : searchEx.parameters.map((parameter: any, i: number) => {
            const formalParameter = formalParameters[i]
            const chooser = formalParameter.ui
            const setValue = (value: any) => {
              const newParameters = [...searchEx.parameters]
              newParameters[i] = value
              setSearchEx(searchEx.shallowCopy({ parameters: newParameters }))
            }
            if (presentChooserWithRadio(chooser)) {
              return (
                <ChooserRadios
                  key={i}
                  chooser={chooser}
                  value={parameter}
                  setValue={setValue}
                />
              )
            } else if (presentChooserWithSelect(chooser)) {
              return <div key={i}>Select chooser</div>
            } else if (presentChooserWithText(chooser)) {
              return <div key={i}>Text chooser</div>
            } else return <div key={i}>Unimplemented chooser</div>
          })}
    </>
  )
}

const ChooserRadios = ({
  chooser,
  value,
  setValue,
}: {
  chooser: Chooser
  value: any
  setValue: (x: any) => void
}) => {
  const options: [string, string][] = (radioChooserNameOptions as any)[
    chooser.name
  ]
  return (
    <>
      {options.map(([value2, label], i) => (
        <label key={i}>
          <input
            type="radio"
            value={value2}
            checked={value === value2}
            onChange={() => setValue(value2)}
          />
          {" " + label}
        </label>
      ))}
    </>
  )
}

const radioChooserNameOptions = {
  chooser_boolean: [["*", "*"], [true, "yes"], [false, "no"]],
  chooser_spin: [["*", "*"], [true, "clockwise"], [false, "ccw"]],
  chooser_left_right_spin: [["*", "*"], [true, "left"], [false, "right"]],
  chooser_right_left_hand: [["*", "*"], [false, "left"], [true, "right"]],
  chooser_right_left_shoulder: [["*", "*"], [false, "left"], [true, "right"]],
  chooser_slide: [["*", "*"], [true, "left"], [false, "right"]],
  chooser_slice_increment: [["*", "*"], "couple", "dancer"],
  chooser_go_back: [
    ["*", "*"],
    [true, "forward &amp; back"],
    [false, "forward"],
  ],
  chooser_give: [["*", "*"], [true, "give &amp; take"], [false, "take"]],
  chooser_half_or_full: [["*", "*"], [0.5, "half"], [1.0, "full"]],
}

const presentChooserWithRadio = (chooser: Chooser) => {
  return chooser.name in radioChooserNameOptions
}
const presentChooserWithSelect = (chooser: Chooser) => false
const presentChooserWithText = (chooser: Chooser) =>
  chooser.name === "chooser_text"

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
