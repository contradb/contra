import React from "react"
import { SearchEx, FigureSearchEx } from "./search-ex"
import FigureSearchExEditorExtras from "./figure-search-ex-editor-extras"
import { copy, paste } from "./search-ex-clipboard"

const makeOpOption = (op: string, i: number): JSX.Element => {
  if (op === "____")
    return (
      <option key={i} style={{ backgroundColor: "white" }} disabled>
        ————————
      </option>
    )
  else
    return (
      <option key={i} value={op}>
        {op.replace(/-/, " ")}
      </option>
    )
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
  "progression",
  "compare",
].map(makeOpOption)

const numericOpOptions = ["constant", "tag", "count-matches"].map(makeOpOption)

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
    <div className="search-ex" {...(id ? { id: id } : {})}>
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
                          s1 && setSearchEx(s1)
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
            {searchEx.subexpressions.map((subex, i) => (
              <SearchExEditor
                key={i}
                searchEx={subex}
                setSearchEx={newsub =>
                  setSearchEx(searchEx.replace(subex, newsub))
                }
                removeSearchEx={subexpressionRemoveFn}
              />
            ))}
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
  if (searchEx instanceof FigureSearchEx) {
    return (
      <FigureSearchExEditorExtras
        searchEx={searchEx as FigureSearchEx}
        setSearchEx={setSearchEx}
      />
    )
  } else {
    return null
  }
}

export default SearchExEditor
