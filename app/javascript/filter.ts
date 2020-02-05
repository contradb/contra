type FigureFilterParameter = number | string | boolean // a guess definition, haven't researched it

export type Comparison = "≥" | "≤" | "≠" | "=" | ">" | "<"

export type Filter =
  | ["figure", string, ...FigureFilterParameter[]]
  | ["&", ...Filter[]]
  | ["and", ...Filter[]]
  | ["or", ...Filter[]]
  | ["then", ...Filter[]]
  | ["not", Filter]
  | ["no", Filter]
  | ["formation", string]
  | ["progression"]
  | ["if", Filter, Filter]
  | ["if", Filter, Filter, Filter]
  | ["all", Filter]
  | ["choreographer", string]
  | ["count", Filter, Comparison, number]
  | ["compare", NumericFilter, Comparison, NumericFilter]
  | ["my tag", string]

export type NumericFilter =
  | ["constant", number]
  | ["tag", string]
  | ["count-matches", Filter]

export default Filter
