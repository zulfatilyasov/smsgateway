React = require 'react'
MessageList = require './messageList.cjsx'

Incoming = React.createClass
    render: ->
        <div>
            <MessageList section="incoming" />
        </div>
module.exports = Incoming