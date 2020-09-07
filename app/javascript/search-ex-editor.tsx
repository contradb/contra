import React from "react"
import {
  SearchEx,
  FigureSearchEx,
  CompareSearchEx,
  ConstantNumericEx,
} from "./search-ex"
import FigureSearchExEditorExtras from "./figure-search-ex-editor-extras"
import ConstantNumericExEditorExtras from "./constant-numeric-ex-editor-extras"
import { copy, paste } from "./search-ex-clipboard"

const makeOpOption = (
  op: string | { label: string; searchEx: string },
  i: number
): JSX.Element => {
  if (op === "____")
    return (
      <option key={i} style={{ backgroundColor: "white" }} disabled>
        ————————
      </option>
    )
  else {
    const label = typeof op === "string" ? op.replace(/-/, " ") : op.label
    const searchExClass = typeof op === "string" ? op : op.searchEx
    return (
      <option key={i} value={searchExClass}>
        {label}
      </option>
    )
  }
}

const nonNumericOpOptions = [
  "figure",
  "or",
  "and",
  "then",
  "no",
  "not",
  "all",
  "progress with",
  "____",
  "&",
  "compare",
].map(makeOpOption)

const numericOpOptions = [
  { label: "number", searchEx: "constant" },
  "count-matches",
  { label: "count verified tags", searchEx: "tag" },
].map(makeOpOption)

const preventDefaultThen = (funcToCall: (event: any) => void) => (event: {
  preventDefault: () => void
}) => {
  event.preventDefault()
  funcToCall(event)
}

export const SearchExEditor = ({
  searchEx,
  setSearchEx,
  removeSearchEx,
  id,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
  removeSearchEx: null | ((se: SearchEx) => void)
  id?: string
}): JSX.Element => {
  const hasEnoughChildrenToRemoveOne =
    searchEx.subexpressions.length > searchEx.minSubexpressions()
  const subexpressionRemoveFn = hasEnoughChildrenToRemoveOne
    ? (sub: SearchEx) => setSearchEx(searchEx.remove(sub))
    : null
  const subexpressionsGrowFn = preventDefaultThen(() =>
    setSearchEx(searchEx.withAdditionalSubexpression())
  )

  return (
    <div className="search-ex" {...(id ? { id } : {})}>
      <div className="search-ex-well">
        <table>
          <tbody>
            <tr>
              <td>
                <select
                  value={searchEx.op}
                  onChange={e => {
                    const op = e.target.value
                    setSearchEx(searchEx.castTo(op))
                  }}
                  className="form-control search-ex-op"
                >
                  {searchEx.isNumeric()
                    ? numericOpOptions
                    : nonNumericOpOptions}
                </select>
              </td>
              <td>
                <div className="btn-group">
                  <button
                    type="button"
                    className="btn btn-default dropdown-toggle search-ex-menu-toggle"
                    data-toggle="dropdown"
                    aria-haspopup="true"
                    aria-expanded="false"
                  >
                    <span className="glyphicon glyphicon-option-vertical"></span>
                  </button>
                  <ul className="dropdown-menu search-ex-menu-entries">
                    {searchEx.subexpressions.length <
                      searchEx.maxSubexpressions() && (
                      <li>
                        <a
                          href="#"
                          className="search-ex-add-subexpression"
                          onClick={subexpressionsGrowFn}
                        >
                          Add
                        </a>
                      </li>
                    )}

                    <li>
                      <a
                        href="#"
                        className="search-ex-copy"
                        onClick={preventDefaultThen(() => copy(searchEx))}
                      >
                        Copy
                      </a>
                    </li>
                    <li>
                      <a
                        href="#"
                        className="search-ex-paste"
                        onClick={preventDefaultThen(() => {
                          const s1 = paste()
                          s1 &&
                            s1.isNumeric() === searchEx.isNumeric() &&
                            setSearchEx(s1)
                        })}
                      >
                        Paste
                      </a>
                    </li>
                    {removeSearchEx && (
                      <>
                        <li role="separator" className="divider"></li>
                        <li>
                          <a
                            href="#"
                            className="search-ex-cut"
                            onClick={preventDefaultThen(() => {
                              copy(searchEx)
                              removeSearchEx(searchEx)
                            })}
                          >
                            Cut
                          </a>
                        </li>
                        <li>
                          <a
                            href="#"
                            className="search-ex-delete"
                            onClick={preventDefaultThen(() =>
                              removeSearchEx(searchEx)
                            )}
                          >
                            Delete
                          </a>
                        </li>
                      </>
                    )}
                  </ul>
                </div>
              </td>
            </tr>
            <EditorExtras searchEx={searchEx} setSearchEx={setSearchEx} />
          </tbody>
        </table>
        {0 === searchEx.subexpressions.length ? null : (
          <div className="search-ex-subexpressions">
            {searchEx.subexpressions.map((subex, i) => {
              const child = (
                <SearchExEditor
                  key={i}
                  searchEx={subex}
                  setSearchEx={newsub =>
                    setSearchEx(searchEx.replace(subex, newsub))
                  }
                  removeSearchEx={subexpressionRemoveFn}
                />
              )
              if (i === 1) {
                if (isCompareSearchEx(searchEx)) {
                  const setValue = (value: string): void =>
                    setSearchEx(
                      searchEx.shallowCopy({
                        comparison: value,
                      })
                    )
                  return (
                    <React.Fragment key={1}>
                      <InfixSelect
                        value={searchEx.comparison}
                        setValue={setValue}
                        options={searchEx.comparisonOptions()}
                      />
                      {child}
                    </React.Fragment>
                  )
                }
              }
              return child
            })}
          </div>
        )}
      </div>
    </div>
  )
}

const EditorExtras = ({
  searchEx,
  setSearchEx,
}: {
  searchEx: SearchEx
  setSearchEx: (se: SearchEx) => void
}): JSX.Element | null => {
  if (isFigureSearchEx(searchEx)) {
    return (
      <FigureSearchExEditorExtras
        searchEx={searchEx}
        setSearchEx={setSearchEx}
      />
    )
  } else if (isConstantNumericEx(searchEx)) {
    return (
      <ConstantNumericExEditorExtras
        searchEx={searchEx}
        setSearchEx={setSearchEx}
      />
    )
  } else {
    return null
  }
}

const InfixSelect = ({
  value,
  setValue,
  options,
}: {
  value: string
  setValue: (s: string) => void
  options: string[]
}): JSX.Element => (
  <div className="search-ex-infix-centerer">
    <select
      className="form-control search-ex-infix"
      value={value}
      onChange={e => setValue(e.target.value)}
    >
      {options.map(op => (
        <option key={op}>{op}</option>
      ))}
    </select>
  </div>
)

// these really belongs in search-ex.js, but can't go there because its too typescripty
const isCompareSearchEx = (searchEx: SearchEx): searchEx is CompareSearchEx =>
  !!(searchEx as CompareSearchEx).comparisonOptions

const isFigureSearchEx = (searchEx: SearchEx): searchEx is FigureSearchEx =>
  !!(searchEx as FigureSearchEx).move

const isConstantNumericEx = (
  searchEx: SearchEx
): searchEx is ConstantNumericEx => {
  return typeof (searchEx as ConstantNumericEx).number === "number"
}

export default SearchExEditor
