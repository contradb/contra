declare class SearchEx {
  toLisp(): Filter
  isNumeric(): boolean
  infixOptions(): undefined | string[]
  get op(): string
  castTo(op: string): SearchEx
  subexpressions: SearchEx[]
  shallowCopy: (any) => SearchEx
  minSubexpressions: () => number
  maxSubexpressions: () => number
  minUsefulSubexpressions: () => number
  replace(from: SearchEx, to: SearchEx): SearchEx
  remove(target: SearchEx): SearchEx
  withAdditionalSubexpression(se?: SearchEx): SearchEx
  toJson(): string
}

declare class FigureSearchEx extends SearchEx {
  get move(): string
  get parameters(): any[]
  get ellipsis(): boolean
}
