// I really don't understand why this is required, but 'static default()' is not.
declare class SearchEx {
  // static default(): SearchEx
  toLisp(): Filter
  isNumeric(): boolean
  get op(): string
  get ellipsis(): boolean
  castTo(op: string): SearchEx
  subexpressions: SearchEx[]
  shallowCopy: (any) => SearchEx
  minSubexpressions: () => number
  maxSubexpressions: () => number
  minUsefulSubexpressions: () => number
  replace(from: SearchEx, to: SearchEx): SearchEx
  remove(target: SearchEx): SearchEx
  withAdditionalSubexpression(se?: SearchEx): SearchEx
}

declare class FigureSearchEx extends SearchEx {
  get move(): string
  get parameters(): any[]
  get ellipsis(): boolean
}

// declare module "*"
