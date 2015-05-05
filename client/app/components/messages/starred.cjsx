React = require 'react'
MessageList = require './messageList.cjsx'
messageStore = require '../../stores/MessageStore.es6'
userStore = require '../../stores/UserStore.coffee'
messageActions = require '../../actions/MessageActions.coffee'
userActions = require '../../actions/UserActions.coffee'
headerEvents = require '../../headerEvents.coffee'

section = 'starred'

getState = ->
    messages: messageStore.MessageList

Starred = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('Starred')
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
                <div className="no-messages">No messages</div>

        }
        </div>
module.exports = Starred