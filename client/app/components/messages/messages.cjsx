React = require 'react'
{TextField,Tabs, Tab, Paper, FontIcon, RaisedButton} = require 'material-ui'
Table = require '../table/table.jsx'
styles = require './messages.styl'
FormElements = require './form-inner.jsx'
messageStore = require '../../stores/MessageStore.es6'
userStore = require '../../stores/UserStore.coffee'
messageActions = require '../../actions/MessageActions.coffee'
userActions = require '../../actions/UserActions.coffee'
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'

getState = ->
    messages: messageStore.MessageList

Messages = React.createClass
    render: ->
        menuItems = [
            {route: 'allmessages', text: 'All messages',iconClassName:'icon icon-chat'}
            {route: 'outcoming', text: 'Outcoming', iconClassName:'icon icon-arrow-with-circle-left'}
            {route: 'incoming', text: 'Incoming',iconClassName:'icon icon-arrow-with-circle-right'}
            {route: 'starred', text: 'Starred',iconClassName:'icon icon-settings'}
        ]
        <Paper zDepth={1}>
            <div className="section">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                       <h2>Outcoming Messages</h2>  
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                       <h4>Compose new message</h4>  
                    </ReactCSSTransitionGroupAppear>
                </div>

                <div className="section-body">
                    <PageWithNav menuItems={menuItems}/>
                </div>
            </div>
        </Paper>

    getInitialState: ->
        messages:messageStore.MessageList
    
    componentDidMount: ->
        if userStore.isAuthenticated()
            messageActions.getUserMessages(userStore.userId())
        else 
            userActions.logout()
        messageStore.addChangeListener(@_onChange)

    componentWillUnmount: ->
        messageStore.removeChangeListener(@_onChange)
        messageActions.clean()
    
    _onChange:->
        @setState(getState()) 

module.exports = Messages