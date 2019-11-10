/////////////////////////////////////////////////////////////////

import * as React from "react"
import * as ReactDOM from "react-dom"
// import './index.css';
import App from "../app"
// import * as serviceWorker from './serviceWorker';
const root = document.getElementById("root")

console.log("root = ", root)
ReactDOM.render(<App />, root)

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
// serviceWorker.unregister();
