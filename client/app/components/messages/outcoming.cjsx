React = require 'react'
MessageList = require './messageList.cjsx'
headerEvents = require '../../headerEvents.coffee'

Outcoming = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('Outcoming')

    render: ->
        <div>
            <MessageList section="outcoming" />
        </div>
module.exports = Outcoming