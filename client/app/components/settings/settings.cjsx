React = require 'react'
mui = require 'material-ui'
Paper = mui.Paper;

Settings = React.createClass
    render: ->
        <Paper zDepth={1}>
            <form className="message-form">
                <h2 className="header">Settings</h2>
                <h4>Subscription and others</h4>
            </form>
        </Paper>

module.exports = Settings