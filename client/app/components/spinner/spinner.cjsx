styles = require './spinner.styl'
React = require('react')

Spinner = React.createClass

  render: ->
         <svg className={"spinner " +  if @props.show then '' else 'hide'} width={@props.width} height={@props.height} viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">
             <circle className="path" fill="none" strokeWidth="3" strokeLinecap="round" cx="33" cy="33" r="30"></circle>
         </svg>

module.exports = Spinner
