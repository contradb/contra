// I really don't understand why this is required, but 'static default()' is not.
declare class SearchEx {
  // static default(): SearchEx
  toLisp(): Filter
  isNumeric(): boolean
  op(): string
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

// declare module "*"
