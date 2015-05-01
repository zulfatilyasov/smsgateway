React = require 'react'
MessageList = require './messageList.cjsx'

Outcoming = React.createClass
    render: ->
        <div>
            <MessageList section="all" />
        </div>
module.exports = Outcoming