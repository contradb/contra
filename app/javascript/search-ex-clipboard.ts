import { SearchEx } from "./search-ex"

export const paste = (): SearchEx | null => {
  const s = localStorage.getItem(key)
  return s ? SearchEx.fromLisp(JSON.parse(s)) : null
}

export const copy = (searchEx: SearchEx | null): void =>
  localStorage.setItem(key, searchEx ? JSON.stringify(searchEx.toLisp()) : "")

const key = "SearchExClipboard"
