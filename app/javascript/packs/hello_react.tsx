

// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import "core-js/stable";
import "regenerator-runtime/runtime";

import * as React from "react"
import * as ReactDOM from "react-dom"
import * as PropTypes from "prop-types"
import { Demo } from "../demo"

const Hello = (props: {name: string}) => (
  <div>
    Hello {props.name}!<Demo />
  </div>
)

// Hello.defaultProps = {
//   name: "David",
// }

// Hello.propTypes = {
//   name: PropTypes.string,
// }

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Hello name={"math"} />,
    document.body.appendChild(document.createElement("div"))
  )
})
