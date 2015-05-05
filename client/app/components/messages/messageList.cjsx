React = require 'react'
MessageItem = require './message-item.cjsx'
messageStore = require '../../stores/MessageStore.es6'
$ = require '../../services/zepto.js'

animateItems = ->
    delay = 50
    $('.animated').each (i, el) ->
        $(@)
            .css("-webkit-animation-delay", i*delay+'ms')
            .css("-o-animation-delay", i*delay+'ms')
            .css("animation-delay", i*delay+'ms')
            .addClass('active')

getState = ->
    loading:messageStore.InProgress

MessageList = React.createClass
    render: ->
        <div>
            {
                console.log @props.messages.length
                if @props.messages.length 
                    for msg in @props.messages by -1
                        <MessageItem  key={msg.id} {...msg} />
                else
                    if @state.loading
                        <div className="no-messages"></div>
                    else 
                        <div></div>
            }
        </div>

    getInitialState: ->
        loading: messageStore.InProgress

    componentDidMount: ->
        messageStore.addChangeListener(@_onChange)
        animateItems()

    componentWillUnmount: ->
        messageStore.removeChangeListener(@_onChange)
    
    _onChange:->
        @setState(getState()) 

module.exports = MessageList