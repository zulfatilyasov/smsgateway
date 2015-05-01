React = require 'react'
MessageList = require './messageList.cjsx'
headerEvents = require '../../headerEvents.coffee'

Incoming = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('Incoming')
        
    render: ->
        <div>
            <MessageList section="incoming" />
        </div>
module.exports = Incoming