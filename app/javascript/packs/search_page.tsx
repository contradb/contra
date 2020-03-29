/////////////////////////////////////////////////////////////////

import * as React from "react"
import * as ReactDOM from "react-dom"
// import './index.css';
import AdvancedSearch from "../advanced-search"
// import * as serviceWorker from './serviceWorker';
const root = document.getElementById("root")
const dialectElement: any = document.getElementById("dialect-json")
const tagsElement: any = document.getElementById("tag-names-json")

const dialect: Dialect = JSON.parse(dialectElement.textContent)
const tags: string[] = JSON.parse(tagsElement.textContent)

ReactDOM.render(<AdvancedSearch dialect={dialect} tags={tags} />, root)

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
// serviceWorker.unregister();
