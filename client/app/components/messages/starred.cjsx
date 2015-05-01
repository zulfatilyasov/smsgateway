React = require 'react'
MessageList = require './messageList.cjsx'
headerEvents = require '../../headerEvents.coffee'

Starred = React.createClass
    componentDidMount: ->
        headerEvents.emitChange('Starred')

    render: ->
        <div>
            <MessageList section="starred" />
        </div>
module.exports = Starred