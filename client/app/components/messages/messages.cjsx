React = require 'react'
mui = require 'material-ui'
messageActions = require '../../actions/MessageActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{Paper, MenuItem} = mui
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'

Messages = React.createClass
    onItemClick: (item)->
        if item.payload
            userId  = userStore.userId()
            messageActions.getUserMessages(userId, item.payload)

    render: ->
        menuItems = [
            {route: 'allmessages', text: 'All messages',iconClassName:'icon icon-chat'}
            {route: 'outcoming', text: 'Outcoming', iconClassName:'icon icon-arrow-with-circle-left'}
            {route: 'incoming', text: 'Incoming',iconClassName:'icon icon-arrow-with-circle-right'}
            {route: 'starred', text: 'Starred',iconClassName:'icon icon-star'}
            {text: 'Status', iconClassName:'icon icon-star', type: MenuItem.Types.NESTED, items:[
                { payload: 'sent', text: 'Sent', iconClassName:'icon icon-arrow-with-circle-left' }
                { payload: 'queued', text: 'Queued', iconClassName:'icon icon-repeat'}
                { payload: 'cancelled', text: 'Cancelled', iconClassName:'icon icon-close' }
                { payload: 'failed', text: 'Failed', iconClassName:'icon icon-sms-failed' }
            ]}
        ]
        <Paper zDepth={1}>
            <div className="section">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                       <h2>Messages</h2>  
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                       <h4>Search history or compose new message</h4>  
                    </ReactCSSTransitionGroupAppear>
                </div>

                <div className="section-body">
                    <PageWithNav onMenuItemClick={@onItemClick} menuItems={menuItems}/>
                </div>
            </div>
        </Paper>

module.exports = Messages