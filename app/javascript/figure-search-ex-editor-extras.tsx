import React, { useState, useEffect, useContext } from "react"
import useDebounce from "./use-debounce"
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
      {skipParams ? null : (
        <table>
          <tbody>
            {searchEx.parameters.map((parameter: any, i: number) => {
              const formalParameter = formalParameters[i]
              const chooser = formalParameter.ui
              const setValue = (value: any) => {
                const newParameters = [...searchEx.parameters]
                newParameters[i] = value
                setSearchEx(searchEx.shallowCopy({ parameters: newParameters }))
              }
              const label = LibFigure.parameterLabel(searchEx.move, i)
              return (
                <tr key={i}>
                  <td className="chooser-label-text">
                    <label>{label}</label>
                  </td>
                  <td>
                    <ChooserChooser
                      chooser={chooser}
                      value={parameter}
                      setValue={setValue}
                      dialect={dialect}
                      move={searchEx.move}
                    />
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      )}
    </>
  )
}

const ChooserChooser = ({
  chooser,
  value,
  setValue,
  dialect,
  move,
}: {
  chooser: Chooser
  value: any
  setValue: (x: any) => void
  dialect: Dialect
  move: string
}) => {
  if (presentChooserWithRadio(chooser)) {
    return <ChooserRadios chooser={chooser} value={value} setValue={setValue} />
  } else if (presentChooserWithSelect(chooser)) {
    return (
      <ChooserSelect
        chooser={chooser}
        value={value}
        setValue={setValue}
        dialect={dialect}
        move={move}
      />
    )
  } else if (presentChooserWithText(chooser)) {
    return (
      <ChooserText
        chooser={chooser}
        value={value}
        setValue={setValue}
        dialect={dialect}
      />
    )
  } else return <div>Unimplemented chooser</div>
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
  const options: [string, string][] = (radioChooserOptions as any)[chooser.name]
  return (
    <div className="flex">
      {options.map(([value2, label], i) => (
        <label key={i}>
          <input
            type="radio"
            value={value2}
            checked={value === value2}
            onChange={() => setValue(value2)}
            className="radio-inline"
          />
          {" " + label}
        </label>
      ))}
    </div>
  )
}

const ChooserSelect = ({
  chooser,
  value,
  setValue,
  dialect,
  move,
}: {
  chooser: Chooser
  value: any
  setValue: (x: any) => void
  dialect: Dialect
  move: string
}) => {
  const optionsfn: (
    move: string,
    d: Dialect
  ) => Array<string | [string, string]> = selectChooserOptions[chooser.name]
  const options = optionsfn(move, dialect)
  return (
    <select
      className="form-control"
      value={value}
      onChange={e => setValue(e.target.value)}
    >
      {options.map((option, i: number) => {
        const [val, label] = Array.isArray(option) ? option : [option, option]
        return (
          <option key={i} value={val}>
            {label}
          </option>
        )
      })}
    </select>
  )
}

const ChooserText = ({
  chooser,
  value,
  setValue,
  dialect,
}: {
  chooser: Chooser
  value: any
  setValue: (x: any) => void
  dialect: Dialect
}) => {
  const [bouncyValue, setBouncyValue] = useState(value)
  const debouncedValue = useDebounce(bouncyValue)
  useEffect(() => setValue(debouncedValue), [debouncedValue])
  return (
    <input
      className="form-control"
      type="text"
      placeholder="any words..."
      value={bouncyValue}
      onChange={e => setBouncyValue(e.target.value)}
    />
  )
}

const radioChooserOptions = {
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

const angleOptions = (move: string, dialect: Dialect) => [
  "*",
  ...LibFigure.anglesForMove(move).map((angle: number) => [
    angle.toString(),
    LibFigure.degreesToWords(angle, move),
  ]),
]

const selectChooserOptions = {
  chooser_revolutions: angleOptions,
  chooser_places: angleOptions,
  chooser_beats: (move: string, dialect: Dialect) => [
    "*",
    8,
    16,
    0,
    1,
    2,
    3,
    4,
    6,
    8,
    10,
    12,
    14,
    16,
    20,
    24,
    32,
    48,
    64,
  ],
  chooser_boolean: (move: string, dialect: Dialect) => [
    "*",
    [true, "yes"],
    [false, "no"],
  ],
  chooser_star_grip: (move: string, dialect: Dialect) =>
    ["*"].concat(
      LibFigure.wristGrips.map(function(grip: any) {
        return grip === "" ? ["", "unspecified"] : grip
      })
    ),
  chooser_march_facing: (move: string, dialect: Dialect) => [
    "*",
    "forward",
    "backward",
    "forward then backward",
  ],
  chooser_set_direction: (move: string, dialect: Dialect) => [
    "*",
    ["along", "along the set"],
    ["across", "across the set"],
    "right diagonal",
    "left diagonal",
  ],
  chooser_set_direction_acrossish: (move: string, dialect: Dialect) => [
    "*",
    ["across", "across the set"],
    "right diagonal",
    "left diagonal",
  ],
  chooser_set_direction_grid: (move: string, dialect: Dialect) => [
    "*",
    ["along", "along the set"],
    ["across", "across the set"],
  ],
  chooser_set_direction_figure_8: (move: string, dialect: Dialect) => [
    "*",
    "",
    "above",
    "below",
    "across",
  ],
  chooser_gate_direction: (move: string, dialect: Dialect) => [
    "*",
    ["up", "up the set"],
    ["down", "down the set"],
    ["in", "into the set"],
    ["out", "out of the set"],
  ],
  chooser_slice_return: (move: string, dialect: Dialect) => [
    "*",
    ["straight", "straight back"],
    ["diagonal", "diagonal back"],
    "none",
  ],
  chooser_all_or_center_or_outsides: (move: string, dialect: Dialect) => [
    "*",
    "all",
    "center",
    "outsides",
  ],
  chooser_down_the_hall_ender: (move: string, dialect: Dialect) => [
    "*",
    ["turn-alone", "turn alone"],
    ["turn-couple", "turn as a couple"],
    ["circle", "bend into a ring"],
    ["cozy", "form a cozy line"],
    ["cloverleaf", "bend into a cloverleaf"],
    ["thread-needle", "thread the needle"],
    ["right-high", "right hand high, left hand low"],
    ["sliding-doors", "sliding doors"],
    ["", "unspecified"],
  ],
  chooser_zig_zag_ender: (move: string, dialect: Dialect) => [
    "*",
    ["", "none"],
    ["ring", "into a ring"],
    ["allemande", "training two catch hands"],
  ],
  chooser_hey_length: (move: string, dialect: Dialect) => [
    "*",
    "full",
    "half",
    "less than half",
    "between half and full",
  ],
  chooser_swing_prefix: (move: string, dialect: Dialect) => [
    "*",
    "none",
    "balance",
    "meltdown",
  ],
  ...LibFigure.dancerChooserNames().reduce(
    (acc: any, chooserName: ChooserName) => {
      acc[chooserName] = (move: string, dialect: Dialect) =>
        ["*"].concat(
          LibFigure.dancerMenuForChooser(LibFigure.chooser(chooserName)).map(
            (dancers: ChooserName) => [
              // I guess that dancers has type ChooserName...?
              dancers,
              LibFigure.dancerMenuLabel(dancers, dialect),
            ]
          )
        )
      return acc
    },
    {}
  ),
}

const presentChooserWithRadio = (chooser: Chooser) =>
  chooser.name in radioChooserOptions
const presentChooserWithSelect = (chooser: Chooser) =>
  chooser.name in selectChooserOptions
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
