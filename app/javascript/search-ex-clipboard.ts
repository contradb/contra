import { SearchEx } from "./search-ex"

export const paste = (): SearchEx | null => {
  const s = sessionStorage.getItem(key)
  return s ? SearchEx.fromLisp(JSON.parse(s)) : null
}

export const copy = (searchEx: SearchEx | null): void =>
  sessionStorage.setItem(key, searchEx ? JSON.stringify(searchEx.toLisp()) : "")

const key = "SearchExClipboard"
