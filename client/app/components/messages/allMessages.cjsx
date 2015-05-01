React = require 'react'
MessageList = require './messageList.cjsx'
headerEvents = require '../../headerEvents.coffee'

AllMessages = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('All messages')

    render: ->
        <div>
            <MessageList section="all" />
        </div>
module.exports = AllMessages