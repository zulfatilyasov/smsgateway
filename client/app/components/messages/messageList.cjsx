React = require 'react'
MessageItem = require './message-item.cjsx'
$ = require '../../services/zepto.js'

animateItems = ->
    delay = 20
    console.log 'animating items'
    $('.animated').each (i, el) ->
        unless $(@).is('.active')
            $(@)
                .css("-webkit-transition-delay", i*delay+'ms')
                .css("-o-transition-delay", i*delay+'ms')
                .css("transition-delay", i*delay+'ms')
                .addClass('active')

MessageList = React.createClass
    componentDidMount: ->
        animateItems()

    componentDidUpdate: (prevProps, prevState) ->
        animateItems()

    render: ->
        console.log 'rendering messages lists'
        <div>
            {
                for msg in @props.messages by -1
                    msg.key = msg.id
                    <MessageItem {...msg} />
            }
        </div>

    

module.exports = MessageList