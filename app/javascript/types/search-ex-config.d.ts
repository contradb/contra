// I really don't understand why this is required, but 'static default()' is not.
declare class SearchEx {
  // static default(): SearchEx
  toLisp(): Filter
  isNumeric(): boolean
  op(): string
  castTo(op: string): SearchEx
}

// declare module "*"
