React = require 'react'
MessageList = require './messageList.cjsx'

AllMessages = React.createClass
    render: ->
        <div>
            <MessageList section="outcoming" />
        </div>
module.exports = AllMessages