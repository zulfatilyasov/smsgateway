React = require 'react'
MessageItem = require './message-item.cjsx'
$ = require '../../services/zepto.js'

animateItems = ->
    delay = 20
    $('.animated').each (i, el) ->
        $(@)
            .css("-webkit-transition-delay", i*delay+'ms')
            .css("-o-transition-delay", i*delay+'ms')
            .css("transition-delay", i*delay+'ms')
            .addClass('active')

MessageList = React.createClass
    componentDidMount: ->
        animateItems()

    render: ->
        console.log 'loading lists' + @props.loading
        <div>
            {
                for msg in @props.messages by -1
                    msg.key = msg.id
                    <MessageItem {...msg} />
            }
        </div>

    

module.exports = MessageList