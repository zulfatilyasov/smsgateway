React = require 'react'

Container = React.createClass

  render: ->
      <div>{@props.children}</div>

module.exports = Container