React = require 'react'
Table = require '../table/table.jsx'
messageStore = require '../../stores/MessageStore.es6'
userStore = require '../../stores/UserStore.coffee'
messageActions = require '../../actions/MessageActions.coffee'
userActions = require '../../actions/UserActions.coffee'
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
routeStore = require '../../stores/RouteStore.coffee'
MessageItem = require './message-item.cjsx'

State = require('react-router').State

getState = ->
    messages: messageStore.MessageList
    loading: messageStore.InProgress

getMessageItemList = (messages) ->
    messageItems = []
    for message in messages
        messageItems.push  
    messageItems


MessageList = React.createClass

    mixins: [ State ]

    render: ->
        <div>
            {
                if @state.messages.length 
                    for msg in @state.messages by -1
                        <MessageItem  key={msg.id} {...msg} />
                else
                    if @state.loading
                        <div className="no-messages"></div>
                    else 
                        <div className="no-messages">No messages</div>
            }
        </div>

    getInitialState: ->
        messages:messageStore.MessageList
        loading: messageStore.InProgress

    componentDidMount: ->
        messageStore.addChangeListener(@_onChange)
        routeStore.addChangeListener(@_onChange)
        if userStore.isAuthenticated()
            messageActions.getUserMessages(userStore.userId(), @props.section)
        else 
            userActions.logout()

    componentWillUnmount: ->
        messageStore.removeChangeListener(@_onChange)
        routeStore.removeChangeListener(@_onChange)
        messageActions.clean()
    
    _onChange:->
        @setState(getState()) 

module.exports = MessageList