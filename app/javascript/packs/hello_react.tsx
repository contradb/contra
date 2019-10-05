// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const Hello = props => (
  <div>Bonjour {props.name}!</div>
)

Hello.defaultProps = {
  name: 'David'
}

Hello.propTypes = {
  name: PropTypes.string
}

const f = (a:number,b: number): number => a+b

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Hello name={"math" + f(5,6)} />,
    document.body.appendChild(document.createElement('div')),
  )
})
