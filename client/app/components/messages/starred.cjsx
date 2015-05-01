React = require 'react'
MessageList = require './messageList.cjsx'

Starred = React.createClass
    render: ->
        <div>
            <MessageList section="starred" />
        </div>
module.exports = Starred