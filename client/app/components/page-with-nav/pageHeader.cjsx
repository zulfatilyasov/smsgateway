React = require 'react'
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'

PageHeader = React.createClass
  render: ->
    <div className="header">
      <ReactCSSTransitionGroupAppear transitionName="fadeDown">
        <div>{@props.header}</div>
      </ReactCSSTransitionGroupAppear>
    </div>

module.exports = PageHeader