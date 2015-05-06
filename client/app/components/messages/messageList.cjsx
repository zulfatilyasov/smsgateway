React = require 'react'
MessageItem = require './message-item.cjsx'
$ = require '../../services/zepto.js'

animateItems = ->
    delay = 50
    $('.animated').each (i, el) ->
        $(@)
            .css("-webkit-animation-delay", i*delay+'ms')
            .css("-o-animation-delay", i*delay+'ms')
            .css("animation-delay", i*delay+'ms')
            .addClass('active')

MessageList = React.createClass
    render: ->
        <div>
            {
                if @props.messages.length 
                    for msg in @props.messages by -1
                        msg.key = msg.id
                        <MessageItem {...msg} />
                else
                    if @state.loading
                        <div className="no-messages"></div>
                    else 
                        <div></div>
            }
        </div>

    componentDidMount: ->
        animateItems()

module.exports = MessageList