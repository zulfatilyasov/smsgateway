React = require 'react'
MessageList = require './messageList.cjsx'
messageStore = require '../../stores/MessageStore.es6'
userStore = require '../../stores/UserStore.coffee'
messageActions = require '../../actions/MessageActions.coffee'
userActions = require '../../actions/UserActions.coffee'
headerEvents = require '../../headerEvents.coffee'

section = 'all'

getState = ->
    messages: messageStore.MessageList

AllMessages = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('All messages')
        messageStore.addChangeListener(@onChange)
        if userStore.isAuthenticated()
            messageActions.getUserMessages(userStore.userId(), section)
        else 
            userActions.logout()

    componentWillUnmount: ->
        messageStore.removeChangeListener(@onChange)
        messageActions.clean()

    getInitialState: ->
        messages: messageStore.MessageList

    onChange: ->
        @setState getState()

    render: ->
        <div>
        {
            if @state.messages.length
                <MessageList messages={@state.messages} />
            else
                <div></div>

        }
        </div>
module.exports = AllMessages